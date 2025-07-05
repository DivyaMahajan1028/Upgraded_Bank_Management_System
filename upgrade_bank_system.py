#  Final Upgraded Bank Management System Project 

import mysql.connector
import random
import datetime

#   Create connection to MySQL database
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Divya@147",
    database="Bank_management_system"
)
print("Connected:", conn)
mycursor = conn.cursor()

#  Create 'transaction_log' table (Recording every deposit & withdrawal made by user)
mycursor.execute('''
CREATE TABLE IF NOT EXISTS transaction_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20),
    pin INT,
    action VARCHAR(10),
    amount INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
)
''')

#  Create 'customer_info' table ( Account details)
mycursor.execute('''
CREATE TABLE IF NOT EXISTS customer_info (
    Name VARCHAR(20),
    pin INT,
    Balance INT DEFAULT 0
)
''')

# Register new user
def new_user():
    while True:
        n = input("Enter Your Name: ").strip()
        if n.replace(" ", "").isalpha():
            n = n.upper()
            break
        else:
            print("❌ Invalid name. Please enter only alphabets.")
    p = random.randint(1000, 9999)
    print(f"Your PIN is: {p}")
    Amount = 0
    mycursor.execute("INSERT INTO customer_info(Name, pin, Balance) VALUES (%s, %s, %s)", (n, p, Amount))
    conn.commit()
    print("User registered successfully.\n")

# Handle existing user
def existing_user():
    while True:
        N = input("Enter Your Name: ").strip()
        if N.replace(" ", "").isalpha():
            N = N.upper()
            break
        else:
            print("❌ Invalid name. Please enter only alphabets.")

    try:
        P = int(input("Enter Your PIN: "))
    except ValueError:
        print("❌ Invalid PIN. Please enter numbers only.")
        return

    mycursor.execute("SELECT * FROM customer_info WHERE Name = %s AND pin = %s", (N, P))
    result = mycursor.fetchone()

    if result:
        print(f"\n======= 💰 Welcome {N} to Your Account 💰 =======")
        while True:
            print("\nPlease select an option:")
            print("1) Credit")
            print("2) Debit")
            print("3) Check Balance")
            print("4) Delete Account")
            print("5) Show Transaction History")
            print("6) LogOut")

            choice = input("Enter Your Choice (1-6): ")

            if choice == "1":
                try:
                    amount = int(input("Enter amount to deposit: "))
                    if amount <= 0:
                        print("❌ Invalid amount. Must be greater than zero.")
                        continue
                except ValueError:
                    print("❌ Please enter a valid number.")
                    continue
                mycursor.execute("UPDATE customer_info SET Balance = Balance + %s WHERE Name = %s AND pin = %s", (amount, N, P))
                mycursor.execute("INSERT INTO transaction_log (name, pin, action, amount) VALUES (%s, %s, 'credit', %s)", (N, P, amount))
                conn.commit()
                print("Amount credited successfully.")

            elif choice == "2":
                try:
                    amount = int(input("Enter amount to withdraw: "))
                    if amount <= 0:
                        print("❌ Invalid amount. Must be greater than zero.")
                        continue
                except ValueError:
                    print("❌ Please enter a valid number.")
                    continue
                mycursor.execute("SELECT Balance FROM customer_info WHERE Name = %s AND pin = %s", (N, P))
                current_balance = mycursor.fetchone()[0]
                if current_balance >= amount:
                    mycursor.execute("UPDATE customer_info SET Balance = Balance - %s WHERE Name = %s AND pin = %s", (amount, N, P))
                    mycursor.execute("INSERT INTO transaction_log (name, pin, action, amount) VALUES (%s, %s, 'debit', %s)", (N, P, amount))
                    conn.commit()
                    print("Amount debited successfully.")
                else:
                    print("Insufficient balance.")

            elif choice == "3":
                mycursor.execute("SELECT Balance FROM customer_info WHERE Name = %s AND pin = %s", (N, P))
                current_balance = mycursor.fetchone()[0]
                print(f"Your current balance is: Rs {current_balance}")

            elif choice == "4":
                confirm = input("Are you sure you want to delete your account? (yes/no): ").lower()
                if confirm == "yes":
                    mycursor.execute("DELETE FROM customer_info WHERE Name = %s AND pin = %s", (N, P))
                    conn.commit()
                    print("Your account has been deleted.")
                    break
                else:
                    print("Account deletion cancelled.")

            elif choice == "5":
                mycursor.execute("SELECT action, amount, timestamp FROM transaction_log WHERE name = %s AND pin = %s ORDER BY timestamp DESC", (N, P))
                transactions = mycursor.fetchall()
                if not transactions:
                    print("No transaction history available.")
                else:
                    print("\n--- Transaction History ---")
                    for t in transactions:
                        print(f"{t[2]} | {t[0].capitalize()} | Rs {t[1]}")
                    mycursor.execute("SELECT Balance FROM customer_info WHERE Name = %s AND pin = %s", (N, P))
                    current_balance = mycursor.fetchone()[0]
                    print(f"\nCurrent Balance: Rs {current_balance}")

            elif choice == "6":
                print("Thank you for using the system. LogOut Successfully!")
                break

            else:
                print("Invalid choice. Please enter a number between 1 and 6.")
    else:
        print("Incorrect name or PIN. Please try again.\n")

# Main menu
def main():
    while True:
        print("\nWelcome to Bank Management System")
        print("1) NEW USER")
        print("2) EXISTING USER")
        print("3) EXIT")
        choice = input("Enter your choice (1-3): ")

        if choice == "1":
            new_user()
        elif choice == "2":
            existing_user()
        elif choice == "3":
            print("EXIT SUCCESSFULLY!")
            break
        else:
            print("Invalid input. Please enter 1, 2, or 3.")

main()

