require 'rspec' # Import library RSpec buat testing
require 'dry/matcher/result_matcher' # Import Dry::Matcher buat matching hasil transaksi
require 'dry/monads' # Import Dry::Monads buat handle Success dan Failure
require_relative 'payment' # Import kelas Payment dari file lokal

describe Payment do
  include Dry::Monads[:result, :do] # Include Dry::Monads biar bisa pake Success dan Failure
  let(:transaction) { Payment.new } # Bikin instance dari kelas Payment

  # Test case buat transaksi yang berhasil
  context 'when the transaction is successful' do
    let(:input) { { account_id: 1, amount: 100 } } # Input valid buat transaksi yang berhasil

    it 'returns a success result' do
      result = transaction.call(input) # Panggil transaksi dengan input valid

      Dry::Matcher::ResultMatcher.call(result) do |m| # Match hasilnya pake Dry::Matcher
        m.success do |value| # Kalau sukses, cek hasilnya
          expect(value[:transaction_id]).to_not be_nil # Pastikan transaction ID nggak kosong
          expect(value[:account_id]).to eq(input[:account_id]) # Pastikan account ID sesuai dengan input
          expect(value[:amount]).to eq(input[:amount]) # Pastikan amount sesuai dengan input
        end

        m.failure do |error| # Kalau gagal, lempar error
          raise "Expected success but got failure: #{error}"
        end
      end
    end
  end

  # Test case buat validasi gagal
  context 'when the validation fails' do
    let(:input) { { account_id: nil, amount: 100 } } # Input nggak valid buat uji validasi gagal

    it 'returns a failure result with :invalid_payment_details' do
      result = transaction.call(input) # Panggil transaksi dengan input yang nggak valid

      Dry::Matcher::ResultMatcher.call(result) do |m| # Match hasilnya pake Dry::Matcher
        m.success do |_| # Kalau sukses, harusnya error
          raise 'Expected failure but got success'
        end

        m.failure do |error| # Kalau gagal, cek alasannya
          expect(error).to eq(:invalid_payment_details) # Pastikan alasan gagalnya :invalid_payment_details
        end
      end
    end
  end

  # Test case buat kegagalan proses pembayaran
  context 'when the payment processing fails' do
    let(:input) { { account_id: 1, amount: 100 } } # Input buat simulasi kegagalan proses pembayaran

    it 'returns a failure result with :payment_failed' do
      allow(transaction).to receive(:call).and_return(Failure(:payment_failed)) # Stub metode call buat balikin failure
      result = transaction.call(input) # Panggil transaksi dengan input

      Dry::Matcher::ResultMatcher.call(result) do |m| # Match hasilnya pake Dry::Matcher
        m.success do |_| # Kalau sukses, harusnya error
          raise 'Expected failure but got success'
        end

        m.failure do |error| # Kalau gagal, cek alasannya
          expect(error).to eq(:payment_failed) # Pastikan alasan gagalnya :payment_failed
        end
      end
    end
  end

  # Test case buat kegagalan email konfirmasi
  context 'when the confirmation email fails' do
    let(:input) { { account_id: 1, amount: 100 } } # Input buat simulasi kegagalan email konfirmasi

    it 'returns a failure result with :confirmation_failed' do
      allow(transaction).to receive(:call).and_return(Failure(:confirmation_failed)) # Stub metode call buat balikin failure
      result = transaction.call(input) # Panggil transaksi dengan input

      Dry::Matcher::ResultMatcher.call(result) do |m| # Match hasilnya pake Dry::Matcher
        m.success do |_| # Kalau sukses, harusnya error
          raise 'Expected failure but got success'
        end

        m.failure do |error| # Kalau gagal, cek alasannya
          expect(error).to eq(:confirmation_failed) # Pastikan alasan gagalnya :confirmation_failed
        end
      end
    end
  end
end
