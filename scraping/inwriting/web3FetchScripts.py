from web3 import Web3
from web3._utils.events import get_event_data
from eth_utils import event_abi_to_log_topic
import json

#from etherscan import Etherscan
import mysql.connector
from mysql.connector import errorcode

contract_string = '''
{
"abi": [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"approved","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Approval","type":"event","signature":"0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"operator","type":"address"},{"indexed":false,"internalType":"bool","name":"approved","type":"bool"}],"name":"ApprovalForAll","type":"event","signature":"0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"price","type":"uint256"}],"name":"Bought","type":"event","signature":"0x3ccb2ab6980b218b1dd4974b07365cd90a191e170c611da46262fecc208bd661"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"price","type":"uint256"}],"name":"Listed","type":"event","signature":"0x1ea45e30b31292f9d7c5d37d275b2feca555f13f47dce0fdea2f47e8852ecd78"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event","signature":"0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":true,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"Transfer","type":"event","signature":"0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"string","name":"str","type":"string"}],"name":"append_to_NFT","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x91126b0a"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x095ea7b3"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x70a08231"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"buy","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0xd96a094a"},{"inputs":[{"internalType":"uint256","name":"newCost","type":"uint256"}],"name":"change_cost","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x51d78177"},{"inputs":[{"internalType":"uint256","name":"newFee","type":"uint256"}],"name":"change_fee","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x6ceba55e"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"check_if_used","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x4c24c439"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"delist_for_sale","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x2ab8a298"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"getApproved","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x081812fc"},{"inputs":[],"name":"get_cost","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xf4d8a952"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_image","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x72b805c2"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_price","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xd93580ff"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"get_string","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x834ca100"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"operator","type":"address"}],"name":"isApprovedForAll","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xe985e9c5"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"uint256","name":"price","type":"uint256"}],"name":"list_for_sale","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0x01b71aec"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"lock_NFT","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function","signature":"0xf1d14903"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"mint_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x8d2e41e5"},{"inputs":[{"internalType":"string","name":"str","type":"string"},{"internalType":"uint256","name":"price","type":"uint256"}],"name":"mint_and_list_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0x0eb4d8cb"},{"inputs":[{"internalType":"string","name":"str","type":"string"}],"name":"mint_unlocked_NFT","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"payable","type":"function","payable":true,"signature":"0xc99457d1"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x06fdde03"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x8da5cb5b"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"ownerOf","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x6352211e"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x715018a6"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x42842e0e"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"},{"internalType":"bytes","name":"_data","type":"bytes"}],"name":"safeTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xb88d4fde"},{"inputs":[{"internalType":"address","name":"operator","type":"address"},{"internalType":"bool","name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xa22cb465"},{"inputs":[{"internalType":"bytes4","name":"interfaceId","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x01ffc9a7"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0x95d89b41"},{"inputs":[{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"tokenURI","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function","constant":true,"signature":"0xc87b56dd"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x23b872dd"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0xf2fde38b"},{"inputs":[{"internalType":"uint256","name":"amt","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function","signature":"0x2e1a7d4d"}]

}



'''

#mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="inwriting", port = 8888, unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')

mydb = mysql.connector.connect(host="localhost", user="test_user", password="test_user", database="inwriting")
mycursor = mydb.cursor()
                               #, port = 8888, unix_socket='/Applications/MAMP/tmp/mysql/mysql.sock')

sql = "SELECT doneBlockNumber FROM env"
mycursor.execute(sql)
myresult = mycursor.fetchall()
doneBlockNumber = int(myresult[0][0])
blockNumbers = []

url_getString = "https://eth-ropsten.alchemyapi.io/v2/8BhLEDbT6LTNE_qKOPFEt6Y7O7ahURik"
web3_getString = Web3(Web3.HTTPProvider(url_getString))
abi_getString = json.loads(contract_string)['abi']
address_getString = '0xBD41d08C2EDFA1a477aC4a9623B00f8A4A98b096'


def getStringFromTokenID(tokenID):
    c = web3_getString.eth.contract(address=address_getString, abi=abi_getString)
    s = c.functions.get_string(int(tokenID)).call()
    return s


class FetchEvents:
    def __init__(self, provider, address, abi):
        self.w3 = Web3(Web3.HTTPProvider(provider))
        self.contract_address = address
        self.contract_abi = json.loads(contract_string)['abi']

        #with open(abi, 'r') as f:
        #    self.contract_abi = f.read()

        self.myContract = self.w3.eth.contract(address=self.contract_address, abi=self.contract_abi)

    def fetch(self, event="all", startBlock=None):
        if startBlock is None or startBlock == 0:
            startBlock = hex(0)
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
            return [event for event in self.fetch('transfer') if int(event['args']['from'], 16) == 0]
        elif event.lower() == 'notmint':
            return [event for event in self.fetch('transfer') if int(event['args']['from'], 16) != 0]
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


if __name__ == '__main__':
    provider = 'https://eth-ropsten.alchemyapi.io/v2/-3gvm-Frgyhg4NaBXQ8az749xofGKwnR'
    contract_address = '0xBD41d08C2EDFA1a477aC4a9623B00f8A4A98b096'
    path_to_abi = 'ContractName.json'
    events = FetchEvents(provider, contract_address, path_to_abi)

    for event in events.fetch('all', doneBlockNumber):
        try:
           # print(event)

            event_type = ""
            if event['event'] == 'Transfer':
                if int(event["args"]["from"], 16) == 0:
                    event_type = 'mint'
                else:
                    event_type = 'transfer'
            else:
                event_type = event['event'].lower()

            if event_type == 'ownershiptransferred' or event_type == 'approval':
                continue
            blockNumber = event['blockNumber']
            #id, timestamp default
            blockHash = event['blockHash'].hex()
            transactionHash = event['transactionHash'].hex()
            tokenID = event['args']['tokenId']
            fromAddress = ""
            if 'owner' in event['args']:
                fromAddress = event['args']['owner']
            elif 'from' in event['args']:
                fromAddress = event['args']['from']
            else:
                sql = "SELECT owner FROM owners WHERE tokenID = '" + str(tokenID) + "'"
                mycursor.execute(sql)
                myresult = mycursor.fetchall()
                fromAddress = myresult[0][0]

            toAddress = ""
            if 'to' in event['args']:
                toAddress = event['args']['to']
            else:
                toAddress = contract_address



            price = None
            if 'price' in event['args']:
                price = event['args']['price']

            logIndex = event['logIndex']

            if event_type == 'bought' and str(price) == "0":
                event_type = 'unlisted'
                price = None

            blockNumbers.append(int(blockNumber))

            sql = "SELECT * FROM blockchain WHERE transactionHash = %s AND event = %s"
            val = (transactionHash, event_type)
            mycursor.execute(sql, val)
            myresult = mycursor.fetchall()
            if len(myresult) > 0:
                print("continuing")
                continue

            fromAddress = fromAddress.lower()
            toAddress = toAddress.lower()


          #  print('inserting with price', price, "fromAddress", fromAddress, "event", event)
            sql = "INSERT INTO blockchain (blockNumber, blockHash, transactionHash, fromAddress, toAddress, tokenID, event, price, logIndex) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (blockNumber, blockHash, transactionHash, fromAddress, toAddress, tokenID, event_type, price, logIndex)

            print(event_type.upper(), val)


            mycursor.execute(sql, val)
            mydb.commit()

            tokenString = getStringFromTokenID(tokenID)
            if event_type == 'mint':
                sql = "INSERT INTO owners (tokenID, tokenString, owner) VALUES (%s, %s, %s)"
                val = (tokenID, tokenString, toAddress)
                mycursor.execute(sql, val)
                mydb.commit()
                
                strlen = len(tokenString)
                wordCount = len(tokenString.split())-1
                
                sql = "INSERT INTO tokenDetails (tokenID, tokenString, char_count, word_count) VALUES (%s, %s, %s, %s)"
                val = (tokenID, tokenString, strlen, wordCount)
                mycursor.execute(sql, val)
                mydb.commit()

            if event['event'] == 'transfer':
                sql = "UPDATE owners SET owner = %s WHERE tokenID = %s"
                val = (toAddress, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

            if event_type == 'unlisted' or event_type == 'bought':
                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (None, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash) VALUES (%s, %s, %s, %s)"
                val = (event_type, tokenID, price, transactionHash)
                mycursor.execute(sql, val)
                mydb.commit()

            if event_type == 'listed':
                sql = "UPDATE owners SET listed = %s WHERE tokenID = %s"
                val = (True, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "UPDATE owners SET price = %s WHERE tokenID = %s"
                val = (price, tokenID)
                mycursor.execute(sql, val)
                mydb.commit()

                sql = "INSERT INTO trades (event, tokenID, price, transactionHash) VALUES (%s, %s, %s, %s)"
                val = (event_type, tokenID, price, transactionHash)
                mycursor.execute(sql, val)
                mydb.commit()




        except Exception as e:
            print("Skipping", event, "because", e)


    newDoneBlockNumber = max(blockNumbers)# lowest blockNumber from batch we just did
    sql = "UPDATE env SET doneBlockNumber = '" + str(newDoneBlockNumber-10) + "' WHERE alchemy = '" + "https://eth-ropsten.alchemyapi.io/v2/8BhLEDbT6LTNE_qKOPFEt6Y7O7ahURik" + "'"
    mycursor.execute(sql)
    mydb.commit()
