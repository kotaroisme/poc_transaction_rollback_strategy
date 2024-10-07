require 'dry/transaction' # Import Dry::Transaction untuk mengelola alur transaksi
require 'dry/monads' # Import Dry::Monads untuk handle Success dan Failure
require 'dry/monads/do' # Import Dry::Monads Do untuk chaining operasi
require 'dry/matcher/result_matcher' # Import Dry::Matcher untuk matching hasil transaksi

class Payment
  include Dry::Transaction # Include modul Dry::Transaction untuk menggunakan step-step transaksi
  include Dry::Monads[:result, :do] # Include Dry::Monads untuk menggunakan Success dan Failure

  attr_accessor :transaction_id, :force_fail_payment, :force_fail_confirmation # Tambahkan accessor untuk transaction_id dan flag failure

  # Step 1: Validasi detail pembayaran
  step :validate_payment
  # Step 2: Proses pembayaran
  step :process_payment
  # Step 3: Kirim email konfirmasi
  step :send_confirmation

  def initialize
    @force_fail_payment = false # Flag untuk memaksa pembayaran gagal
    @force_fail_confirmation = false # Flag untuk memaksa konfirmasi gagal
    @executed_steps = [] # Untuk melacak langkah-langkah yang telah dijalankan
  end

  # Method untuk memulai transaksi
  def call(input)
    result = validate_payment(input).bind do |validated_input|
      process_payment(validated_input).bind do |processed_input|
        send_confirmation(processed_input)
      end
    end

    Dry::Matcher::ResultMatcher.call(result) do |m|
      m.success do |value|
        Success(value)
      end
      m.failure do |failure|
        rollback!(failure)
        Failure(failure)
      end
    end
  end

  # Method untuk validasi pembayaran
  def validate_payment(input)
    if input[:amount] > 0 && input[:account_id] # Cek apakah amount lebih dari 0 dan account_id ada
      @executed_steps << :validate_payment
      Success(input) # Jika valid, kembalikan Success dengan input
    else
      Failure(:invalid_payment_details) # Jika tidak valid, kembalikan Failure dengan simbol :invalid_payment_details
    end
  end

  # Method untuk memproses pembayaran
  def process_payment(input)
    if force_fail_payment # Cek apakah pembayaran dipaksa gagal
      Failure(:payment_failed) # Jika dipaksa gagal, kembalikan Failure dengan simbol :payment_failed
    else
      self.transaction_id = "txn_123" # Tetapkan transaction_id ke input untuk konsistensi
      input[:transaction_id] = transaction_id # Simpan transaction_id untuk konsistensi
      @executed_steps << :process_payment
      Success(input) # Kembalikan Success dengan input yang sudah diperbarui
    end
  end

  # Method untuk mengirim email konfirmasi
  def send_confirmation(input)
    if force_fail_confirmation # Cek apakah konfirmasi dipaksa gagal
      Failure(:confirmation_failed) # Jika dipaksa gagal, kembalikan Failure dengan simbol :confirmation_failed
    else
      puts "Confirmation email sent for Transaction ID: #{input[:transaction_id]}" # Cetak pesan konfirmasi
      @executed_steps << :send_confirmation
      Success(input) # Kembalikan Success dengan input
    end
  end

  # Method rollback untuk menjalankan rollback strategy
  def rollback!(failure)
    @executed_steps.reverse_each do |step|
      case step
      when :validate_payment
        rollback_validate_payment(failure)
      when :process_payment
        rollback_process_payment(failure)
      when :send_confirmation
        rollback_send_confirmation(failure)
      end
    end
  end

  # Rollback untuk validasi pembayaran
  def rollback_validate_payment(failure)
    puts "Rollback: Membatalkan validasi pembayaran karena #{failure}." # Proses rollback untuk validasi pembayaran jika gagal
  end

  # Rollback untuk memproses pembayaran
  def rollback_process_payment(failure)
    puts "Rollback: Mengembalikan dana untuk account_id karena #{failure}." # Proses rollback untuk pembayaran jika gagal
  end

  # Rollback untuk mengirim konfirmasi
  def rollback_send_confirmation(failure)
    puts "Rollback: Gagal mengirim email konfirmasi untuk Transaction ID: #{transaction_id} karena #{failure}." # Proses rollback untuk email konfirmasi jika gagal
  end
end
