## Directory Structure
```sh
- poc_transaction_rollback_strategy
  -- payment.rb
  -- payment_spec.rb
  -- Gemfile
  -- Gemfile.lock
```

##  Setup

1. **Clone or Navigate to the Project Folder**

   Make sure you are in the `poc_transaction_rollback_strategy` folder where all the application files are located.

2. **Install Dependencies with Bundler**

   Bundler is used to manage the gems required by the application. Make sure you have bundler installed, if not, install it with:
   ```sh
   gem install bundler
   ```

3. **Install Dependencies**

   Once `bundler` is installed, run the following command to install all required dependencies based on the `Gemfile`:
   ```sh
   bundle install
   ```

## Running Code with IRB

1. **Open IRB**

   IRB is the Interactive Ruby Shell that can be used to run Ruby code directly in the terminal. To open IRB, type:
   ```sh
   irb
   ```

2. **Load `payment.rb` File into IRB**

   After IRB is open, load the `payment.rb` file so that it can be used in IRB:
   ```ruby
   require_relative 'payment'
   ```

3. **Create an Instance and Execute a Transaction**

   After successfully loading the `payment.rb` file, you can create an instance of the `Payment` class and execute a transaction using `Dry::Matcher::ResultMatcher`, for example:
   ```ruby
   transaction = Payment.new
   result = transaction.call(account_id: 1, amount: 100)

   # Check the result of the transaction using Dry::Matcher::ResultMatcher
   Dry::Matcher::ResultMatcher.call(result) do |m|
     m.success do |value|
       puts "Transaction successful: #{value}"
     end

     m.failure do |error|
       puts "Transaction failed: #{error}"
     end
   end
   transaction = Payment.new
   result = transaction.call(account_id: 1, amount: 100)
   
   # Check the result of the transaction
   if result.success?
     puts "Transaction successful: #{result.value!}"
   else
     puts "Transaction failed: #{result.failure}"
   end
   ```

## Running RSpec

1. **Ensure RSpec is Installed**

   RSpec is a gem for testing in Ruby. Make sure it is installed via `bundle install`. If not, add `rspec` to the `Gemfile` and run:
   ```sh
   bundle install
   ```

2. **Run Tests with RSpec**

   To run the tests in `payment_spec.rb`, use the following command:
   ```sh
   bundle exec rspec payment_spec.rb
   ```
   This command will run all the test cases in the `payment_spec.rb` file and display the results in the terminal.

## Additional Notes

- Make sure all files (`payment.rb` and `payment_spec.rb`) are in the same directory.
- If any errors occur during installation or while running the code, ensure that all required gems or libraries are installed and listed in the `Gemfile`.