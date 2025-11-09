//Abstract Base Class — BankAccount (Encapsulation + Abstraction)

abstract class BankAccount {
  // Private fields
  String _accountNumber;
  String _accountHolderName;
  double _balance;

  // Keep a list of transactions (Step 4 feature)
  final List<String> _transactions = [];

  BankAccount(this._accountNumber, this._accountHolderName, this._balance);

  // Getters and Setters (Encapsulation)
  String get accountNumber => _accountNumber;
  String get accountHolderName => _accountHolderName;
  double get balance => _balance;

  set accountHolderName(String name) {
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
    _accountHolderName = name;
  }

  // Abstract methods — implemented differently by each account type
  void deposit(double amount);
  void withdraw(double amount);

  // Helper methods (used by subclasses)
  void _applyDeposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit must be positive');
    _balance += amount;
    _addTransaction('Deposited \$${amount.toStringAsFixed(2)}');
  }

  void _applyWithdrawal(double amount) {
    if (amount <= 0) throw ArgumentError('Withdrawal must be positive');
    _balance -= amount;
    _addTransaction('Withdrew \$${amount.toStringAsFixed(2)}');
  }

  // Display account information
  void displayInfo() {
    print('--- Account Info ---');
    print('Account Number : $_accountNumber');
    print('Holder Name    : $_accountHolderName');
    print('Balance        : \$${_balance.toStringAsFixed(2)}');
    print('--------------------');
//Transaction History 
  void _addTransaction(String details) => _transactions.add(details);

  void showTransactionHistory() {
    print('\n📜 Transaction History for $_accountHolderName ($_accountNumber):');
    if (_transactions.isEmpty) {
      print('No transactions yet.');
    } else {
      for (var t in _transactions) print('- $t');
    }
  }
}
Interface — InterestBearing

abstract class InterestBearing {
  double calculateInterest();
}



// SavingsAccount (Inheritance + Polymorphism)


class SavingsAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 500;
  static const double _interestRate = 0.02;
  static const int _withdrawalLimit = 3;

  int _withdrawals = 0;

  SavingsAccount(String acc, String name, double bal)
      : super(acc, name, bal) {
    if (bal < _minBalance) {
      throw ArgumentError('Need at least \$$_minBalance to open SavingsAccount');
    }
  }

  @override
  void deposit(double amount) {
    _applyDeposit(amount);
    print('Deposited \$${amount.toStringAsFixed(2)} into SavingsAccount');
  }

  @override
  void withdraw(double amount) {
    if (_withdrawals >= _withdrawalLimit) {
      print('Withdrawal limit reached');
      return;
    }
    if (balance - amount < _minBalance) {
      print('Cannot go below minimum balance of \$$_minBalance');
      return;
    }
    _applyWithdrawal(amount);
    _withdrawals++;
    print('Withdrew \$${amount.toStringAsFixed(2)} from SavingsAccount');
  }

  @override
  double calculateInterest() => balance * _interestRate;

  void applyMonthlyInterest() {
    double interest = calculateInterest();
    _applyDeposit(interest);
    print('Interest of \$${interest.toStringAsFixed(2)} added to SavingsAccount');
  }
}

//CheckingAccount

class CheckingAccount extends BankAccount {
  static const double _overdraftFee = 35;

  CheckingAccount(String acc, String name, double bal)
      : super(acc, name, bal);

  @override
  void deposit(double amount) {
    _applyDeposit(amount);
    print('Deposited \$${amount.toStringAsFixed(2)} into CheckingAccount');
  }

  @override
  void withdraw(double amount) {
    _applyWithdrawal(amount);
    if (balance < 0) {
      print('Overdraft! Fee of \$$_overdraftFee charged.');
      _applyWithdrawal(_overdraftFee);
    } else {
      print('Withdrew \$${amount.toStringAsFixed(2)} from CheckingAccount');
    }
  }
}
// PremiumAccount

class PremiumAccount extends BankAccount implements InterestBearing {
  static const double _minBalance = 10000;
  static const double _interestRate = 0.05;

  PremiumAccount(String acc, String name, double bal)
      : super(acc, name, bal) {
    if (bal < _minBalance) {
      throw ArgumentError('Need at least \$$_minBalance to open PremiumAccount');
    }
  }

  @override
  void deposit(double amount) {
    _applyDeposit(amount);
    print('Deposited \$${amount.toStringAsFixed(2)} into PremiumAccount');
  }

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print('Cannot withdraw more than available balance');
      return;
    }
    _applyWithdrawal(amount);
    print('Withdrew \$${amount.toStringAsFixed(2)} from PremiumAccount');
  }

  @override
  double calculateInterest() => balance * _interestRate;

  void applyMonthlyInterest() { //polimorphism
    double interest = calculateInterest();
    _applyDeposit(interest);
    print('Interest of \$${interest.toStringAsFixed(2)} added to PremiumAccount');
  }
}    
// StudentAccount (New Account Type)
class StudentAccount extends BankAccount {
  static const double _maxBalance = 5000;

  StudentAccount(String acc, String name, double bal)
      : super(acc, name, bal) {
    if (bal > _maxBalance) {
      throw ArgumentError('Initial balance cannot exceed \$$_maxBalance');
    }
  }

  @override
  void deposit(double amount) {
    if (balance + amount > _maxBalance) {
      print('Cannot exceed max balance of \$$_maxBalance');
      return;
    }
    _applyDeposit(amount);
    print('Deposited \$${amount.toStringAsFixed(2)} into StudentAccount');
  }

  @override
  void withdraw(double amount) {
    if (balance - amount < 0) {
      print('Insufficient balance — cannot withdraw.');
      return;
    }
    _applyWithdrawal(amount);
    print('Withdrew \$${amount.toStringAsFixed(2)} from StudentAccount');
  }
}



// Bank Class (Manages All Accounts)


class Bank {
  final List<BankAccount> _accounts = [];

  // Add account
  void addAccount(BankAccount account) {
    if (_accounts.any((a) => a.accountNumber == account.accountNumber)) {
      print('Account ${account.accountNumber} already exists!');
      return;
    }
    _accounts.add(account);
    print('✅ Account ${account.accountNumber} added.');
  }

  // Find account
  BankAccount? findAccount(String accNum) {
    try {
      return _accounts.firstWhere((a) => a.accountNumber == accNum);
    } catch (e) {
      print('❌ No account found with number $accNum');
      return null;
    }
  }

  // Transfer
  void transfer(String fromAccNum, String toAccNum, double amount) {
    var fromAcc = findAccount(fromAccNum);
    var toAcc = findAccount(toAccNum);

    if (fromAcc == null || toAcc == null) {
      print('Transfer failed: invalid account number.');
      return;
    }

    print('\n🔁 Transfer \$${amount.toStringAsFixed(2)} from $fromAccNum to $toAccNum');
    fromAcc.withdraw(amount);
    toAcc.deposit(amount);
    print('✅ Transfer complete!');
  }

  // Show all accounts
  void showAllAccounts() {
    print('\n===== Bank Report: All Accounts =====');
    for (var acc in _accounts) {
      acc.displayInfo();
    }
    print('=====================================');
  }

 //  Apply Interest to All InterestBearing Accounts =====
void applyMonthlyInterestToAll() {
  print('\n💰 Applying Monthly Interest to All Eligible Accounts...');
  for (var acc in _accounts) {
    if (acc is InterestBearing) {
      // ✅ Cast acc as InterestBearing before calling calculateInterest()
      var interest = (acc as InterestBearing).calculateInterest();

      acc.deposit(interest);
      print('Interest \$${interest.toStringAsFixed(2)} applied to ${acc.accountNumber}');
    }
  }
}

}



// Demo Main Function

void main() {
  var bank = Bank();

  // Create accounts
  var sav = SavingsAccount('SAV1001', 'Alice', 1500);
  var chk = CheckingAccount('CHK2001', 'Bob', 500);
  var pre = PremiumAccount('PRE3001', 'Charlie', 20000);
  var stu = StudentAccount('STU4001', 'David', 3000);

  // Add them to bank
  bank.addAccount(sav);
  bank.addAccount(chk);
  bank.addAccount(pre);
  bank.addAccount(stu);

  // Show all accounts
  bank.showAllAccounts();

  // Transfer demo
  bank.transfer('SAV1001', 'CHK2001', 300);

  // Apply monthly interest to all
  bank.applyMonthlyInterestToAll();

  // Final bank report
  bank.showAllAccounts();

  // Show individual transaction histories
  sav.showTransactionHistory();
  chk.showTransactionHistory();
  pre.showTransactionHistory();
  stu.showTransactionHistory();
}

