require 'dry/transaction' # Import Dry::Transaction untuk mengelola alur transaksi
require 'dry/monads' # Import Dry::Monads untuk handle Success dan Failure
require 'dry/monads/do' # Import Dry::Monads Do untuk chaining operasi
require 'dry/matcher/result_matcher' # Import Dry::Matcher untuk matching hasil transaksi

class Payment
  include Dry::Transaction # Include modul Dry::Transaction untuk menggunakan step-step transaksi
  include Dry::Monads[:result, :do] # Include Dry::Monads untuk menggunakan Success dan Failure

  # Step 1: Validasi detail pembayaran
  step :validate_payment
  # Step 2: Proses pembayaran
  step :process_payment
  # Step 3: Kirim email konfirmasi
  step :send_confirmation

  # Method untuk validasi pembayaran
  def validate_payment(input)
    if input[:amount] > 0 && input[:account_id] # Cek apakah amount lebih dari 0 dan account_id ada
      Success(input) # Jika valid, kembalikan Success dengan input
    else
      Failure(:invalid_payment_details) # Jika tidak valid, kembalikan Failure dengan simbol :invalid_payment_details
    end
  end

  # Method untuk memproses pembayaran
  def process_payment(input)
    # Bayangkan memproses pembayaran di sini...
    # Simulasikan pembayaran yang berhasil
    input[:transaction_id] = "txn_#{rand(1000)}" # Tambahkan transaction_id ke input
    Success(input) # Kembalikan Success dengan input yang sudah diperbarui
  rescue
    Failure(:payment_failed) # Jika terjadi error, kembalikan Failure dengan simbol :payment_failed
  end

  # Method untuk mengirim email konfirmasi
  def send_confirmation(input)
    # Bayangkan mengirim email di sini...
    puts "Confirmation email sent for Transaction ID: #{input[:transaction_id]}" # Cetak pesan konfirmasi
    Success(input) # Kembalikan Success dengan input
  rescue
    Failure(:confirmation_failed) # Jika terjadi error, kembalikan Failure dengan simbol :confirmation_failed
  end
end
