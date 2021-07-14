/*
 * SPDX-License-Identifier: Apache-2.0
 */

package org.hyperledger.fabric.samples.mybook;

import java.util.ArrayList;
import java.util.List;

import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contact;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.License;
import org.hyperledger.fabric.contract.annotation.Transaction;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ledger.KeyValue;
import org.hyperledger.fabric.shim.ledger.QueryResultsIterator;

import com.owlike.genson.Genson;

/**
 * Java implementation of the MyBook Contract described in the Writing Your
 * First Application tutorial
 */
@Contract(
        name = "MyBook",
        info = @Info(
                title = "MyBook contract",
                description = "The Books Contract",
                version = "0.0.1-SNAPSHOT",
                license = @License(
                        name = "Apache 2.0 License",
                        url = "http://www.apache.org/licenses/LICENSE-2.0.html"),
                contact = @Contact(
                        email = "mybook@books.com",
                        name = "My books",
                        url = "https://hyperledger.books.com")))
@Default
public final class MyBook implements ContractInterface {

    private final Genson genson = new Genson();

    private enum MyBookErrors {
        BOOK_NOT_FOUND,
        BOOK_ALREADY_EXISTS
    }

    /**
     * Retrieves a book with the specified key from the ledger.
     *
     * @param ctx the transaction context
     * @param key the key
     * @return the Book found on the ledger if there was one
     */
    @Transaction()
    public Book queryBook(final Context ctx, final String key) {
        ChaincodeStub stub = ctx.getStub();
        String bookState = stub.getStringState(key);

        if (bookState.isEmpty()) {
            String errorMessage = String.format("Book %s does not exist", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, MyBookErrors.BOOK_NOT_FOUND.toString());
        }

        Book book = genson.deserialize(bookState, Book.class);

        return book;
    }

    /**
     * Creates some initial Books on the ledger.
     *
     * @param ctx the transaction context
     */
    @Transaction()
    public void initLedger(final Context ctx) {
        ChaincodeStub stub = ctx.getStub();

        String[] bookData = {
                "{ \"book_id\": \"12A\", \"book_price\": \"500\", \"book_owner\": \"Chandana\", \"current_status\": \"Order Placed\" }",
                "{ \"book_id\": \"12B\", \"book_price\": \"1000\", \"book_owner\": \"Ramya\", \"current_status\": \"Order Placed\" }"
        };

        for (int i = 0; i < bookData.length; i++) {
            String key = String.format("BOOK%d", i);

            Book book = genson.deserialize(bookData[i], Book.class);
            String bookState = genson.serialize(book);
            stub.putStringState(key, bookState);
        }
    }

    /**
     * Creates a new Book on the ledger.
     *
     * @param ctx the transaction context
     * @param key the key for the new book
     * @param book_id the book id of the new book
     * @param book_price the book price of the new book
     * @param book_owner the book owner of the new book
     * @param current_status the current_status of the new book
     * @return the created Book
     */
    @Transaction()
    public Book createBook(final Context ctx, final String key, final String book_id, final String book_price,
            final String book_owner, final String current_status) {
        ChaincodeStub stub = ctx.getStub();

        String bookState = stub.getStringState(key);
        if (!bookState.isEmpty()) {
            String errorMessage = String.format("Book %s already exists", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, MyBookErrors.BOOK_ALREADY_EXISTS.toString());
        }

        Book book = new Book(book_id, book_price, book_owner, current_status);
        bookState = genson.serialize(book);
        stub.putStringState(key, bookState);

        return book;
    }

    /**
     * Retrieves all books from the ledger.
     *
     * @param ctx the transaction context
     * @return array of Books found on the ledger
     */
    @Transaction()
    public String queryAllBooks(final Context ctx) {
        ChaincodeStub stub = ctx.getStub();

        final String startKey = "BOOK1";
        final String endKey = "BOOK99";
        List<BookQueryResult> queryResults = new ArrayList<BookQueryResult>();

        QueryResultsIterator<KeyValue> results = stub.getStateByRange(startKey, endKey);

        for (KeyValue result: results) {
            Book book = genson.deserialize(result.getStringValue(), Book.class);
            queryResults.add(new BookQueryResult(result.getKey(), book));
        }

        final String response = genson.serialize(queryResults);

        return response;
    }

    /**
     * Changes the owner of a book on the ledger.
     *
     * @param ctx the transaction context
     * @param key the key
     * @param newOwner the new owner
     * @return the updated Book
     */
    @Transaction()
    public Book changeBookOwner(final Context ctx, final String key, final String newOwner) {
        ChaincodeStub stub = ctx.getStub();

        String bookState = stub.getStringState(key);

        if (bookState.isEmpty()) {
            String errorMessage = String.format("Book %s does not exist", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, MyBookErrors.BOOK_NOT_FOUND.toString());
        }

        Book book = genson.deserialize(bookState, Book.class);

        Book newBook = new Book(book.getBook_id(), book.getBook_price(), newOwner, book.getCurrent_status());
        String newBookState = genson.serialize(newBook);
        stub.putStringState(key, newBookState);

        return newBook;
    }
    /**
     * Changes the current status of a book on the ledger.
     *
     * @param ctx the transaction context
     * @param key the key
     * @param newStatus the new status
     * @return the updated Book
     */
    @Transaction()
    public Book changeBookStatus(final Context ctx, final String key, final String newStatus) {
        ChaincodeStub stub = ctx.getStub();

        String bookState = stub.getStringState(key);

        if (bookState.isEmpty()) {
            String errorMessage = String.format("Book %s does not exist", key);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, MyBookErrors.BOOK_NOT_FOUND.toString());
        }

        Book book = genson.deserialize(bookState, Book.class);

        Book newBook = new Book(book.getBook_id(), book.getBook_price(), book.getBook_owner(), newStatus);
        String newBookState = genson.serialize(newBook);
        stub.putStringState(key, newBookState);

        return newBook;
    }
}
