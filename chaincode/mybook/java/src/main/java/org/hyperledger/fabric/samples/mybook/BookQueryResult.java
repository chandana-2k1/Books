/*
 * SPDX-License-Identifier: Apache-2.0

 make- book_id
 model- book_price
 color- book_owner
 owner- current_status
 */

package org.hyperledger.fabric.samples.mybook;

import java.util.Objects;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

/**
 * BookQueryResult structure used for handling result of query
 *
 */
@DataType()
public final class BookQueryResult {
    @Property()
    private final String key;

    @Property()
    private final Book record;

    public BookQueryResult(@JsonProperty("Key") final String key, @JsonProperty("Record") final Book record) {
        this.key = key;
        this.record = record;
    }

    public String getKey() {
        return key;
    }

    public Book getRecord() {
        return record;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }

        if ((obj == null) || (getClass() != obj.getClass())) {
            return false;
        }

        BookQueryResult other = (BookQueryResult) obj;

        Boolean recordsAreEquals = this.getRecord().equals(other.getRecord());
        Boolean keysAreEquals = this.getKey().equals(other.getKey());

        return recordsAreEquals && keysAreEquals;
    }

    @Override
    public int hashCode() {
        return Objects.hash(this.getKey(), this.getRecord());
    }

    @Override
    public String toString() {
        return this.getClass().getSimpleName() + "@" + Integer.toHexString(hashCode()) + " [key=" + key + ", record="
                + record + "]";
    }
}
