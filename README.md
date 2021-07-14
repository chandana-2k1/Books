Books

The Books-Network has 4 organisations:
1. sellerorg
2. buyerorg
3. logisticorg
4. bankorg
Each organisation has a peer.

Elements
Ledger has the following data elements:
1. book_id
2. book_price
3. book_owner
4. current_status

Steps:
1. First, buyer V decides what book has to be bought and then places an order
2. Buyer V transfers money to seller C through a Bank A
3. Seller C gives the book to logistic partner R, to deliver it to Buyer V
4. Logistic partner R delivers the book to Buyer V

Network diagram:
![Screenshot from 2021-07-14 13-18-07](https://user-images.githubusercontent.com/66197408/125584137-8a1a3e17-373d-4366-9423-652a01d4e8a8.png)

Run:

Inorder to close the currently running containers: 
./network.sh down

Inorder to bringup the hyperledger fabric network:
./network.sh up createChannel -ca -s couchdb
