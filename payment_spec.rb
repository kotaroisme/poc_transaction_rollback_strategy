require 'rspec' # Import library RSpec buat testing
require 'dry/matcher/result_matcher' # Import Dry::Matcher buat matching hasil transaksi
require 'dry/monads' # Import Dry::Monads buat handle Success dan Failure
require_relative 'payment' # Import kelas Payment dari file lokal

RSpec.describe Payment do
  let(:valid_input) { { amount: 100, account_id: 'acc_456' } }
  let(:invalid_input) { { amount: 0, account_id: nil } }
  let(:payment) { Payment.new }

  describe '#call' do
    context 'when payment is successful' do
      it 'processes the payment and sends confirmation' do
        expect { payment.call(valid_input) }.to output(/Confirmation email sent for Transaction ID: txn_123/).to_stdout

        expect(payment.transaction_id).to eq('txn_123')
        expect(payment.instance_variable_get(:@executed_steps)).to eq([:validate_payment, :process_payment, :send_confirmation])
      end
    end

    context 'when validation fails' do
      it 'fails and rolls back validation' do
        result = payment.call(invalid_input)

        expect(result).to be_failure
        expect(result.failure).to eq(:invalid_payment_details)
        expect(payment.instance_variable_get(:@executed_steps)).to be_empty
      end
    end

    context 'when payment processing fails' do
      it 'fails and rolls back processed steps' do
        payment.force_fail_payment = true

        expect {
          result = payment.call(valid_input)

          expect(result).to be_failure
          expect(result.failure).to eq(:payment_failed)
          expect(payment.instance_variable_get(:@executed_steps)).to eq([:validate_payment])
        }.to output(/Rollback: Membatalkan validasi pembayaran karena payment_failed./).to_stdout
      end
    end

    context 'when sending confirmation fails' do
      it 'fails and rolls back all steps' do
        payment.force_fail_confirmation = true

        expect {
          result = payment.call(valid_input)

          expect(result).to be_failure
          expect(result.failure).to eq(:confirmation_failed)
          expect(payment.instance_variable_get(:@executed_steps)).to eq([:validate_payment, :process_payment])
        }.to output(/Rollback: Mengembalikan dana untuk account_id karena confirmation_failed.\nRollback: Membatalkan validasi pembayaran karena confirmation_failed./).to_stdout
      end
    end
  end

  describe '#rollback!' do
    it 'calls the appropriate rollback methods in reverse order' do
      payment.instance_variable_set(:@executed_steps, [:validate_payment, :process_payment, :send_confirmation])

      expect(payment).to receive(:rollback_send_confirmation).with(:some_failure).ordered
      expect(payment).to receive(:rollback_process_payment).with(:some_failure).ordered
      expect(payment).to receive(:rollback_validate_payment).with(:some_failure).ordered

      payment.rollback!(:some_failure)
    end
  end
end
