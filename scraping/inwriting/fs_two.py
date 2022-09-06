from web3 import Web3
from web3._utils.events import get_event_data
from eth_utils import event_abi_to_log_topic
from etherscan import Etherscan
import json
import mysql.connector
from mysql.connector import errorcode

contract_string = '''

{
"abi": [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"address","name":"addr","type":"address"}],"name":"Appended","type":"event","signature":"0xb77ac2cf2bae3b1d3a17f92a68edca0b214181c2b72dbc133de7491fa2b55751"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event","signature":"0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event","signature":"0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"price","type":"uint256"}],"name":"Bought","type":"event","signature":"0x3ccb2ab6980b218b1dd4974b07365cd90a191e170c611da46262fecc208bd661"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"price","type":"uint256"}],"name":"Listed","type":"event","signature":"0x1ea45e30b31292f9d7c5d37d275b2feca555f13f47dce0fdea2f47e8852ecd78"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event","signature":"0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event","signature":"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"string","name":"str","type":"string"}],"name":"append_to_NFT","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x91126b0a"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x095ea7b3"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x70a08231"},{"inputs":[{"internalType":"string","name":"str1","type":"string"},{"internalType":"string","name":"str2","type":"string"}],"name":"both","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0xe40980c6"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"buy","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0xd96a094a"},{"inputs":[],"name":"buying_fee","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x4f6e7104"},{"inputs":[{"internalType":"uint256","name":"newCost","type":"uint256"}],"name":"change_cost","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x51d78177"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"change_end","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0xaff1aab2"},{"inputs":[{"internalType":"uint256","name":"newFee","type":"uint256"}],"name":"change_fee","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x6ceba55e"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"change_start","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x5d5e3d64"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"check_if_used","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x4c24c439"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"delist_for_sale","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x2ab8a298"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x081812fc"},{"inputs":[],"name":"get_cost","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xf4d8a952"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_image","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x72b805c2"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_price","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xd93580ff"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_string","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x834ca100"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xe985e9c5"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint256","name":"price","type":"uint256"}],"name":"list_for_sale","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x01b71aec"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"lock_NFT","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0xf1d14903"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"mint_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x8d2e41e5"},{"inputs":[{"internalType":"string","name":"str","type":"string"},{"internalType":"uint256","name":"price","type":"uint256"}],"name":"mint_and_list_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x0eb4d8cb"},{"inputs":[{"internalType":"string","name":"str","type":"string"},{"internalType":"uint256","name":"price","type":"uint256"}],"name":"mint_and_list_unlocked_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x6eb02583"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"mint_unlocked_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0xc99457d1"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x06fdde03"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x8da5cb5b"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x6352211e"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x715018a6"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x42842e0e"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"_data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xb88d4fde"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xa22cb465"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x01ffc9a7"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x95d89b41"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xc87b56dd"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x18160ddd"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x23b872dd"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xf2fde38b"},{"inputs":[{"internalType":"uint256","name":"amt","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x2e1a7d4d"}]

}
'''


mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="inwriting")
#mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="inwriting", port = 8888, #unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')
mycursor = mydb.cursor()


class Fetch:
    def __init__(self, provider, address, abi, blockNum, key, network):
        self.w3 = Web3(Web3.HTTPProvider(provider))
        self.contract_address = address
        self.block = blockNum
      #  with open(abi, 'r') as f:
          #  self.contract_abi = f.read()
        self.contract_abi = json.loads(contract_string)['abi']

        self.myContract = self.w3.eth.contract(address=self.contract_address, abi=self.contract_abi)

        self.key = key
        self.eth = Etherscan(key, net=network)

        self.function_dict = {i['signature']: {'name': i['name'],
                                               'inputs': i['inputs'],
                                               'outputs': i['outputs']
                                               } for i in self.myContract.abi if i['type'] == 'function'}
        return

    def events(self, event="all", startBlock=None):
        if startBlock is None or startBlock == 0:
            startBlock = hex(11995816) # default of the start of the contract
        if event.lower() == 'listed':
            return self.myContract.events.Listed.createFilter(fromBlock=f'{startBlock}').get_all_entries()
        elif event.lower() == 'bought':
            return self.myContract.events.Bought.createFilter(fromBlock=f'{startBlock}').get_all_entries()
        elif event.lower() == 'transfer':
            return self.myContract.events.Transfer.createFilter(fromBlock=f'{hex(0)}').get_all_entries()
        elif event.lower() == 'approval':
            return self.myContract.events.Approval.createFilter(fromBlock=f'{hex(0)}').get_all_entries()
        elif event.lower() == 'ownershiptransferred':
            return self.myContract.events.OwnershipTransferred.createFilter(fromBlock=f'{hex(0)}').get_all_entries()
        elif event.lower() == 'mint':
            return [event for event in self.events('transfer') if int(event['args']['from'], 16) == 0]
        elif event.lower() == 'notmint':
            return [event for event in self.events('transfer') if int(event['args']['from'], 16) != 0]
        elif event.lower() == 'all':
            topic2abi = {event_abi_to_log_topic(_): _
                         for _ in self.myContract.abi if _['type'] == 'event'}

            logs = self.w3.eth.getLogs(dict(
                address=self.contract_address,
                fromBlock=startBlock,
                toBlock='latest'
            ))

            _return = []
            for entry in logs:
                topic0 = entry['topics'][0]
                if topic0 in topic2abi:
                    _return.append(get_event_data(self.w3.codec, topic2abi[topic0], entry))
            return _return
        else:
            raise AttributeError(
                'event field must be ["listed", "bought", "transfer", "approval", "ownershiptransferred", '
                '"mint", "notmint", "all"]')

    def transactions(self):
        return [txn['hash'] for txn in self.contract_txns(self.contract_address)]

    def contract_txns(self, address) -> dict:
        txns = self.eth.get_normal_txs_by_address(
            address=address,
            startblock=str(self.block),
            endblock='latest',
            sort='asc'
        )

        return txns

    def functions(self):
        txns = self.transactions()
        transfers = self.contractTransfers()
        txndict = dict()
        for txn in txns:
            # txn is transaction hash
            d = self.w3.eth.get_transaction(txn)
            blockNumber = d.blockNumber
            timestamp = self.w3.eth.get_block(blockNumber).timestamp  # timestamps
            d_receipt = self.w3.eth.get_transaction_receipt(txn)

            print("RECEIPT:", d_receipt)
            print(d)

            data = d['input']
            for key in self.function_dict:
                if data.startswith(str(key)):
                    params = self.myContract.decode_function_input(data)



                    txndict.update({txn: {'function': params[0].fn_name,
                                          'inputs': params[1]}})
                    if params[0].fn_name.startswith('mint'):
                        for t in transfers:
                            if t['hash'] == txn:
                                txndict[txn].update({'tokenId': int(t['tokenID'])})
                                print("IN HERE WITH TOKENID", int(t['tokenID']))
                                break
                    elif 'tokenId' in txndict[txn]['inputs'].keys():
                        txndict[txn].update({'tokenId': txndict[txn]['inputs']['tokenId']})
                        print("IN HERE WITH TOKENID", txndict[txn]['inputs']['tokenId'])

                    txndict[txn].update({'status': d_receipt['status']})
                    txndict[txn].update({'timeStamp': timestamp})
                    txndict[txn].update({'blockNumber': blockNumber})
                    txndict[txn].update({'blockHash': d['blockHash']})
                    txndict[txn].update({'transactionHash': txn})
                    

                    if 'from' in d:
                        txndict[txn].update({'function_caller': d['from']}) # function caller

        return txndict

    def contractTransfers(self) -> dict:
        txns = self.eth.get_erc721_token_transfer_events_by_contract_address_paginated(
            contract_address=self.contract_address,
            page='1',
            offset='10000',
            sort='desc'
        )

        return txns


if __name__ == '__main__':
    provider = 'https://eth-ropsten.alchemyapi.io/v2/-3gvm-Frgyhg4NaBXQ8az749xofGKwnR'
    contract_address = '0x15B108551642177e45A97a1643696fdD381c5241'
    path_to_abi = 'abi.json'
    etherscan_key = 'RM26JUXM7U7VXTX5D77KWVA5IAN7TJUDEZ'

    sql = "SELECT doneBlockNumber FROM env"
    mycursor.execute(sql)
    myresult = mycursor.fetchall()
    doneBlockNumber = int(myresult[0][0])
    blockNumbers = []

    fetch = Fetch(provider, contract_address, path_to_abi, doneBlockNumber, etherscan_key, 'ropsten')

    # print(fetch.functions())

    # print([txn for txn in fetch.contract_txns(fetch.contract_address) if txn['isError'] == '0'])

    # print(fetch.contractTransfers())

    out = fetch.functions()

    for i in out.keys():
        try:
        #print(i, out[i])

            tx = out[i]
          #  print(tx)

            if tx['status'] == 0: # ignore failed transactions
                continue

            print(tx)
            function_name = tx['function']
            blockNumber = tx['blockNumber']
            blockHash = tx['blockHash'].hex()
            timeStamp = tx['timeStamp']
            transactionHash = tx['transactionHash']
            fromAddress = None
            toAddress = None
            if 'to' in tx['inputs']:
                toAddress = tx['inputs']['to']
                toAddress = toAddress.lower()
            if 'from' in tx['inputs']:
                fromAddress = tx['inputs']['from']
                fromAddress = fromAddress.lower()
            tokenID = tx['tokenId']
            price = None
            if 'price' in tx['inputs']:
                price = tx['inputs']['price']
            function_caller = tx['function_caller'].lower()

            sql = "SELECT * FROM blockchain WHERE transactionHash = %s AND function = %s"
            val = (transactionHash, function_name)
            mycursor.execute(sql, val)
            myresult = mycursor.fetchall()
            if len(myresult) > 0:
                print("continuing", function_caller)
                continue
            #fromAddress and toAddress only for if the event is a transfer/buy/sell


            #  print('inserting with price', price, "fromAddress", fromAddress, "event", event)


            if function_name == 'buy':

                sql = "SELECT price FROM owners WHERE tokenID = '" + str(tokenID) + "'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                temp_price = myresult[0][0]

                sql = "INSERT INTO blockchain (blockNumber, timeStamp, blockHash, transactionHash, fromAddress, toAddress, tokenID, function, price, function_caller) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                val = (
                blockNumber, timeStamp, blockHash, transactionHash, fromAddress, toAddress, tokenID, function_name, temp_price,
                function_caller)
                mycursor.execute(sql, val)
                mydb.commit()
            else:
                sql = "INSERT INTO blockchain (blockNumber, timeStamp, blockHash, transactionHash, fromAddress, toAddress, tokenID, function, price, function_caller) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                val = (blockNumber, timeStamp, blockHash, transactionHash, fromAddress, toAddress, tokenID, function_name, price, function_caller)
                mycursor.execute(sql, val)
                mydb.commit()

            blockNumbers.append(int(blockNumber))
            print(function_name.upper(), val)

            ### UPDATING SERVER DB

            if function_name == "mint_NFT":
                sql = "INSERT INTO owners (tokenID, tokenString, owner, locked) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], function_caller, True)
                mycursor.execute(sql, val)
                mydb.commit()

                strlen = len(tx['inputs']['str'])
                wordCount = len(tx['inputs']['str'].split()) - 1
                if wordCount == 0:
                    wordCount = 1

                sql = "INSERT INTO tokenDetails (tokenID, tokenString, char_count, word_count) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], strlen, wordCount)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "mint_and_list_NFT":
                sql = "INSERT INTO owners (tokenID, tokenString, owner, listed, price, locked) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], function_caller, True, tx['inputs']['price'], True)
                mycursor.execute(sql, val)
                mydb.commit()

                strlen = len(tx['inputs']['str'])
                wordCount = len(tx['inputs']['str'].split()) - 1
                if wordCount == 0:
                    wordCount = 1

                sql = "INSERT INTO tokenDetails (tokenID, tokenString, char_count, word_count) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], strlen, wordCount)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                val = ('listed', tokenID, tx['inputs']['price'], transactionHash, timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "mint_and_list_unlocked_NFT":
                sql = "INSERT INTO owners (tokenID, tokenString, owner, listed, price, locked) VALUES (%s, %s, %s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], function_caller, True, tx['inputs']['price'], False)
                mycursor.execute(sql, val)
                mydb.commit()

                strlen = len(tx['inputs']['str'])
                wordCount = len(tx['inputs']['str'].split()) - 1
                if wordCount == 0:
                    wordCount = 1

                sql = "INSERT INTO tokenDetails (tokenID, tokenString, char_count, word_count) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], strlen, wordCount)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                val = ('listed', tokenID, tx['inputs']['price'], transactionHash, timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "mint_unlocked_NFT":
                sql = "INSERT INTO owners (tokenID, tokenString, owner, locked) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], function_caller, False)
                mycursor.execute(sql, val)
                mydb.commit()

                strlen = len(tx['inputs']['str'])
                wordCount = len(tx['inputs']['str'].split()) - 1
                if wordCount == 0:
                    wordCount = 1

                sql = "INSERT INTO tokenDetails (tokenID, tokenString, char_count, word_count) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], strlen, wordCount)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "safeTransferFrom":
                sql = "UPDATE owners SET owner = %s WHERE tokenID = %s"
                val = (toAddress, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "SELECT listed FROM owners WHERE tokenID = '" + str(tokenID) + "'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                previouslyListed = myresult[0][0]

                if previouslyListed:

                    sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                    val = ('delisted', tokenID, 0, transactionHash, timeStamp)
                    mycursor.execute(sql, val)
                    mydb.commit()

            elif function_name == "lock_NFT":
                sql = "UPDATE owners SET locked = %s WHERE tokenID = %s"
                val = (True, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "lock_NFT":
                sql = "UPDATE owners SET locked = %s WHERE tokenID = %s"
                val = (True, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "list_for_sale":
                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (True, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (tx['inputs']['price'], tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                val = ('listed', tokenID, tx['inputs']['price'], transactionHash, timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "delist_for_sale":
                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                val = ('delisted', tokenID, 0, transactionHash, timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()

            elif function_name == "buy":
                sql = "UPDATE owners SET owner = %s WHERE tokenID = %s"
                val = (function_caller, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "SELECT price FROM owners WHERE tokenID = '" + str(tokenID) + "'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                temp_price = myresult[0][0]

                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()


                sql = "INSERT INTO trades (event, tokenID, price, transactionHash, timeStamp) VALUES (%s, %s, %s, %s, %s)"
                val = ('bought', tokenID, temp_price, transactionHash, timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()


            if function_name == "append_to_NFT":
                sql = "INSERT INTO unlockedHistory (tokenID, appended_str, timeStamp) VALUES (%s, %s, %s)"
                val = (tokenID, tx['inputs']['str'], timeStamp)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "SELECT tokenString FROM owners WHERE tokenID = '" + str(tokenID) +"'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                ts = myresult[0][0]

                ts = ts + tx['inputs']['str']
                sql = "UPDATE owners SET tokenString = %s WHERE tokenID = %s"
                val = (ts, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                strlen = len(ts)
                wordCount = len(ts.split()) - 1
                if wordCount == 0:
                    wordCount = 1

                sql = "UPDATE tokenDetails SET tokenString = %s WHERE tokenID = %s"
                val = (ts, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE tokenDetails SET char_count = %s WHERE tokenID = %s"
                val = (strlen, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE tokenDetails SET word_count = %s WHERE tokenID = %s"
                val = (wordCount, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET tokenString = %s WHERE tokenID = %s"
                val = (ts, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()


        except Exception as e:
            print("failed with", i, e)

    blockNumbers = list(set(blockNumbers))
    newDoneBlockNumber = 0
    if len(blockNumbers) == 0:
        pass
    elif len(blockNumbers) == 1:
        newDoneBlockNumber = blockNumbers[0]
        sql = "UPDATE env SET doneBlockNumber = '" + str(
            newDoneBlockNumber) + "' WHERE alchemy = '" + "https://eth-ropsten.alchemyapi.io/v2/8BhLEDbT6LTNE_qKOPFEt6Y7O7ahURik" + "'"
      #  mycursor.execute(sql)
      #  mydb.commit()
    else:
        newDoneBlockNumber = blockNumbers[1]
        sql = "UPDATE env SET doneBlockNumber = '" + str(
            newDoneBlockNumber) + "' WHERE alchemy = '" + "https://eth-ropsten.alchemyapi.io/v2/8BhLEDbT6LTNE_qKOPFEt6Y7O7ahURik" + "'"
      #  mycursor.execute(sql)
      #  mydb.commit()

