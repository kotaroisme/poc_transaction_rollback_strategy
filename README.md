# Payment Transaction with Rollback

This project implements a `Payment` class that manages the payment transaction flow with structured steps, including a rollback mechanism if any step fails. 

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Payment Class Structure](#payment-class-structure)
   - [Transaction Steps](#transaction-steps)
   - [Rollback Mechanism](#rollback-mechanism)
- [Usage](#usage)
- [Testing](#testing)
- [Execution Examples](#execution-examples)
- [License](#license)


## Main Features

- **Payment Validation**: Ensures payment details are valid before processing.
- **Payment Processing**: Processes the payment transaction and generates a `transaction_id`.
- **Send Confirmation**: Sends a confirmation email after a successful payment.
- **Rollback Mechanism**: If any step fails, the system rolls back the previously executed steps.
- **Automated Testing**: Uses RSpec to ensure all functions work as expected.

## Prerequisites

Make sure you have installed:

- Ruby (version 3.x or later)
- Bundler (`gem install bundler`)

## Installation

1. **Clone this repository** or copy the code into your project directory.

2. **Navigate to the project directory**:

   ```bash
   cd your-project-directory
   ```

3. **Install dependencies** with Bundler:

   ```bash
   bundle install
   ```

## Directory Structure
```sh
- poc_transaction_rollback_strategy
  -- payment.rb
  -- payment_spec.rb
  -- Gemfile
  -- Gemfile.lock
```

## Payment Class Structure

The `Payment` class manages the payment transaction flow through three main steps:

### Transaction Steps

1. **`validate_payment`**: Validates payment details like `amount` and `account_id`.
2. **`process_payment`**: Processes the payment and generates a `transaction_id`.
3. **`send_confirmation`**: Sends a confirmation email to the user.

### Rollback Mechanism

If any step fails, the `rollback!` method is called to undo the previously executed steps. Rollback is performed in reverse order of the executed steps.

Available rollback methods:

- `rollback_send_confirmation`
- `rollback_process_payment`
- `rollback_validate_payment`

## Usage

Here's an example of how to use the `Payment` class:

```ruby
require_relative 'payment'

payment = Payment.new

input = {
  amount: 100,
  account_id: 'acc_456'
}

result = payment.call(input)

if result.success?
  puts "Payment successful with Transaction ID: #{payment.transaction_id}"
else
  puts "Payment failed due to: #{result.failure}"
end
```

**Note**: You can force a failure in the payment or confirmation step by setting the `force_fail_payment` or `force_fail_confirmation` attribute to `true`:

```ruby
payment.force_fail_payment = true
payment.force_fail_confirmation = true
```

## Testing

Testing is conducted using RSpec. The tests cover the following scenarios:

- Successful payment without any failures.
- Failure during the payment validation step.
- Failure during the payment processing step.
- Failure during the confirmation sending step.
- Testing the rollback mechanism.

### Running the Tests

1. Ensure you are in the project directory.

2. Run the following command:

   ```bash
   rspec
   ```

3. You will see the test output, indicating whether all tests pass or if any fail.

**Sample Output**:

```
Payment
  #call
    when payment is successful
      processes the payment and sends confirmation
    when validation fails
      fails and rolls back validation
    when payment processing fails
      fails and rolls back processed steps
    when sending confirmation fails
      fails and rolls back all steps
  #rollback!
    calls the appropriate rollback methods in reverse order

Finished in 0.02345 seconds (files took 0.16543 seconds to load)
5 examples, 0 failures
```

## Execution Examples

Below are some execution examples and the output they produce:

### 1. Successful Payment

```ruby
payment = Payment.new
input = { amount: 100, account_id: 'acc_456' }
result = payment.call(input)
```

**Output**:

```
Confirmation email sent for Transaction ID: txn_123
Payment successful with Transaction ID: txn_123
```

### 2. Payment Validation Failure

```ruby
payment = Payment.new
input = { amount: 0, account_id: nil }
result = payment.call(input)
```

**Output**:

```
Rollback: Cancelled payment validation due to invalid_payment_details.
Payment failed due to: invalid_payment_details
```

### 3. Payment Processing Failure

```ruby
payment = Payment.new
payment.force_fail_payment = true
input = { amount: 100, account_id: 'acc_456' }
result = payment.call(input)
```

**Output**:

```
Rollback: Cancelled payment validation due to payment_failed.
Payment failed due to: payment_failed
```

### 4. Confirmation Sending Failure

```ruby
payment = Payment.new
payment.force_fail_confirmation = true
input = { amount: 100, account_id: 'acc_456' }
result = payment.call(input)
```

**Output**:

```
Rollback: Refunded amount to account_id due to confirmation_failed.
Rollback: Cancelled payment validation due to confirmation_failed.
Payment failed due to: confirmation_failed
```