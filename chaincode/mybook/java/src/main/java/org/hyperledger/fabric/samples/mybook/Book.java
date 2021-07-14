/*
 * SPDX-License-Identifier: Apache-2.0
 */

package org.hyperledger.fabric.samples.mybook;

import java.util.Objects;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

@DataType()
public final class Book {

    @Property()
    private final String book_id;

    @Property()
    private final String book_price;

    @Property()
    private final String book_owner;

    @Property()
    private final String current_status;

    public String getBook_id() {
        return book_id;
    }

    public String getBook_price() {
        return book_price;
    }

    public String getBook_owner() {
        return book_owner;
    }

    public String getCurrent_status() {
        return current_status;
    }

    public Book(@JsonProperty("book_id") final String book_id, @JsonProperty("book_price") final String book_price,
            @JsonProperty("book_owner") final String book_owner, @JsonProperty("current_status") final String current_status) {
        this.book_id = book_id;
        this.book_price = book_price;
        this.book_owner = book_owner;
        this.current_status = current_status;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        Book other = (Book) obj;

        return Objects.deepEquals(new String[] {getBook_id(), getBook_price(), getBook_owner(), getCurrent_status()},
                new String[] {other.getBook_id(), other.getBook_price(), other.getBook_owner(), other.getCurrent_status()});
    }

    @Override
    public int hashCode() {
        return Objects.hash(getBook_id(), getBook_price(), getBook_owner(), getCurrent_status());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [book_id=" + book_id + ", book_price="
                + book_price + ", book_owner=" + book_owner + ", current_status=" + current_status + "]";
    }
}
