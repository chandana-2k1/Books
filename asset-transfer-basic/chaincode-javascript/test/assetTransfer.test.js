/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
*/

'use strict';
const sinon = require('sinon');
const chai = require('chai');
const sinonChai = require('sinon-chai');
const expect = chai.expect;

const { Context } = require('fabric-contract-api');
const { ChaincodeStub } = require('fabric-shim');

const AssetTransfer = require('../lib/assetTransfer.js');

let assert = sinon.assert;
chai.use(sinonChai);

describe('Asset Transfer Basic Tests', () => {
    let transactionContext, chaincodeStub, asset;
    beforeEach(() => {
        transactionContext = new Context();

        chaincodeStub = sinon.createStubInstance(ChaincodeStub);
        transactionContext.setChaincodeStub(chaincodeStub);

        chaincodeStub.putState.callsFake((key, value) => {
            if (!chaincodeStub.states) {
                chaincodeStub.states = {};
            }
            chaincodeStub.states[key] = value;
        });

        chaincodeStub.getState.callsFake(async (key) => {
            let ret;
            if (chaincodeStub.states) {
                ret = chaincodeStub.states[key];
            }
            return Promise.resolve(ret);
        });

        chaincodeStub.deleteState.callsFake(async (key) => {
            if (chaincodeStub.states) {
                delete chaincodeStub.states[key];
            }
            return Promise.resolve(key);
        });

        chaincodeStub.getStateByRange.callsFake(async () => {
            function* internalGetStateByRange() {
                if (chaincodeStub.states) {
                    // Shallow copy
                    const copied = Object.assign({}, chaincodeStub.states);

                    for (let key in copied) {
                        yield {value: copied[key]};
                    }
                }
            }

            return Promise.resolve(internalGetStateByRange());
        });

        asset = {
            bookid: '123A',
            bookprice: '1000',
            bookowner: 'Universal Book Store',
            currentstatus: 'Order placed',
        };
    });

    describe('Test InitLedger', () => {
        it('should return error on InitLedger', async () => {
            chaincodeStub.putState.rejects('failed inserting key');
            let assetTransfer = new AssetTransfer();
            try {
                await assetTransfer.InitLedger(transactionContext);
                assert.fail('InitLedger should have failed');
            } catch (err) {
                expect(err.name).to.equal('failed inserting key');
            }
        });

        it('should return success on InitLedger', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.InitLedger(transactionContext);
            let ret = JSON.parse((await chaincodeStub.getState('123A')).toString());
            expect(ret).to.eql(Object.assign({docType: 'asset'}, asset));
        });
    });

    describe('Test CreateAsset', () => {
        it('should return error on CreateAsset', async () => {
            chaincodeStub.putState.rejects('failed inserting key');

            let assetTransfer = new AssetTransfer();
            try {
                await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);
                assert.fail('CreateAsset should have failed');
            } catch(err) {
                expect(err.name).to.equal('failed inserting key');
            }
        });

        it('should return success on CreateAsset', async () => {
            let assetTransfer = new AssetTransfer();

            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            let ret = JSON.parse((await chaincodeStub.getState(asset.bookid)).toString());
            expect(ret).to.eql(asset);
        });
    });

    describe('Test ReadAsset', () => {
        it('should return error on ReadAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            try {
                await assetTransfer.ReadAsset(transactionContext, 'asset2');
                assert.fail('ReadAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset 123B does not exist');
            }
        });

        it('should return success on ReadAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            let ret = JSON.parse(await chaincodeStub.getState(asset.bookid));
            expect(ret).to.eql(asset);
        });
    });

    describe('Test UpdateAsset', () => {
        it('should return error on UpdateAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            try {
                await assetTransfer.UpdateAsset(transactionContext, '123B', '1100', 'Universal Book Store', 'Order placed');
                assert.fail('UpdateAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset 123B does not exist');
            }
        });

        it('should return success on UpdateAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            await assetTransfer.UpdateAsset(transactionContext, '123A', '1000', 'Universal Book Store', 'Order placed');
            let ret = JSON.parse(await chaincodeStub.getState(asset.bookid));
            let expected = {
                bookid: '123A',
                bookprice: '1000',
                bookowner: 'Universal Book Store',
                currentstatus: 'Order placed'
            };
            expect(ret).to.eql(expected);
        });
    });

    describe('Test DeleteAsset', () => {
        it('should return error on DeleteAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            try {
                await assetTransfer.DeleteAsset(transactionContext, '123B');
                assert.fail('DeleteAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset 123B does not exist');
            }
        });

        it('should return success on DeleteAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            await assetTransfer.DeleteAsset(transactionContext, asset.bookid);
            let ret = await chaincodeStub.getState(asset.bookid);
            expect(ret).to.equal(undefined);
        });
    });

    describe('Test TransferAsset', () => {
        it('should return error on TransferAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            try {
                await assetTransfer.TransferAsset(transactionContext, '123B', 'Universal Book Store');
                assert.fail('DeleteAsset should have failed');
            } catch (err) {
                expect(err.message).to.equal('The asset 123B does not exist');
            }
        });

        it('should return success on TransferAsset', async () => {
            let assetTransfer = new AssetTransfer();
            await assetTransfer.CreateAsset(transactionContext, asset.bookid, asset.bookprice, asset.bookowner, asset.currentstatus);

            await assetTransfer.TransferAsset(transactionContext, asset.bookid, 'Universal Book Store');
            let ret = JSON.parse((await chaincodeStub.getState(asset.bookid)).toString());
            expect(ret).to.eql(Object.assign({}, asset, {bookowner: 'Universal Book Store'}));
        });
    });

    describe('Test GetAllAssets', () => {
        it('should return success on GetAllAssets', async () => {
            let assetTransfer = new AssetTransfer();

            await assetTransfer.CreateAsset(transactionContext, '123A', '1000', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123B', '1100', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123C', '500', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123D', '900', 'Universal Book Store', 'Order placed');

            let ret = await assetTransfer.GetAllAssets(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: {bookid: '123A', bookprice: '1000', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}},
                {Record: {bookid: '123B', bookprice: '1100', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}},
                {Record: {bookid: '123C', bookprice: '500', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}},
                {Record: {bookid: '123D', bookprice: '900', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}}
            ];

            expect(ret).to.eql(expected);
        });

        it('should return success on GetAllAssets for non JSON value', async () => {
            let assetTransfer = new AssetTransfer();

            chaincodeStub.putState.onFirstCall().callsFake((key, value) => {
                if (!chaincodeStub.states) {
                    chaincodeStub.states = {};
                }
                chaincodeStub.states[key] = 'non-json-value';
            });

            await assetTransfer.CreateAsset(transactionContext, '123A', '1000', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123B', '1100', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123C', '500', 'Universal Book Store', 'Order placed');
            await assetTransfer.CreateAsset(transactionContext, '123D', '900', 'Universal Book Store', 'Order placed');

            let ret = await assetTransfer.GetAllAssets(transactionContext);
            ret = JSON.parse(ret);
            expect(ret.length).to.equal(4);

            let expected = [
                {Record: 'non-json-value'},
                {Record: {bookid: '123B', bookprice: '1100', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}},
                {Record: {bookid: '123C', bookprice: '500', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}},
                {Record: {bookid: '123D', bookprice: '900', bookowner: 'Universal Book Store', currentstatus: 'Order placed'}}
            ];

            expect(ret).to.eql(expected);
        });
    });
});
