import React, { useState, useEffect } from 'react';
import DataDappContract from './contracts/DataDappContract.json';
import getWeb3 from './getWeb3';

import './App.css';

const App = () => {
  // Component level State
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState(null);
  const [account, setAccount] = useState(null);

  const [dataDappContract, setDataDappContract] = useState(null);

  async function getAccount() {
    const accounts = await ethereum.enable();
    setAccount(accounts[0]);
  }
  const ethereum = window.ethereum;
  if (ethereum) {
    ethereum.on('accountsChanged', function (accounts) {
      getAccount();
    });
  }

  // Hook that triggers when component did mount
  useEffect(() => {
    async function fetchData() {
      try {
        // Get network provider and web3 instance
        const web3Instance = await getWeb3();
        setWeb3(web3Instance);

        // Use web3 to get the user's accounts
        const accountsInstance = await web3Instance.eth.getAccounts();
        setAccounts(accountsInstance);
        setAccount(accountsInstance[0]);

        // Get the network id
        const networkId = await web3Instance.eth.net.getId();

        // Get contract instances
        const dataDappContractInstance = new web3Instance.eth.Contract(
          DataDappContract.abi,
          DataDappContract.networks[networkId] &&
            DataDappContract.networks[networkId].address
        );
        setDataDappContract(dataDappContractInstance);

        dataDappContractInstance.events
          .DepositEvent()
          .on('data', async function (evt) {
            console.log(evt);
          });
      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`
        );
        console.error(error);
      }
    }
    fetchData();
  }, []);

  //id:...03 -> owner     , pk:...d6 , a:...8f
  //id:...04 -> requester , pk:...0a , a:...47
  //id:...2c -> packet

  //From Owner (id:...03) (pk:...d6) (a:...8f)
  const register1 = async () => {
    let result = await dataDappContract.methods
      .registerUser('606969f43ec3002e086b8003')
      .send({ from: account });
    console.log(result);
  };

  //From Requester (id:...04) (pk:...0a) (a:...47)
  const register2 = async () => {
    let result = await dataDappContract.methods
      .registerUser('606969f43ec3002e086b8004')
      .send({ from: account });
    console.log(result);
  };

  const getRegister1UP = async () => {
    let result = await dataDappContract.methods
      .getRegisterUsers('606969f43ec3002e086b8003')
      .send({ from: account });
    console.log(result);
  };

  const getRegister2UP = async () => {
    let result = await dataDappContract.methods
      .getRegisterUsers('606969f43ec3002e086b8004')
      .send({ from: account });
    console.log(result);
  };

  //From Owner (id:...03) (pk:...d6) (a:...8f)
  const upload = async () => {
    let result = await dataDappContract.methods
      .addUpload('606969f43ec3002e086b8003', '60884e9f56ff2c2b48aaa22c', [
        'QmUr3hKzJhaG5xwk3TJ1ZWMfWw84MWXbqfj7xEKdTdLKrq',
        'Qmb1XQVqTHGp33U73SFbASoooURxBs4VtNi2N5gFksobwQ'
      ])
      .send({ from: account });
    console.log(result);
  };

  //From Requester (id:...04) (pk:...0a) (a:...47)
  const sample = async () => {
    let result = await dataDappContract.methods
      .addSampleRequest(
        '606969f43ec3002e086b8004',
        '60884e9f56ff2c2b48aaa22c',
        [
          'QmUr3hKzJhaG5xwk3TJ1ZWMfWw84MWXbqfj7xEKdTdLKrq',
          'Qmb1XQVqTHGp33U73SFbASoooURxBs4VtNi2N5gFksobwQ'
        ]
      )
      .send({ from: account });
    console.log(result);
  };

  //From Requester (id:...04) (pk:...0a) (a:...47)
  const review = async () => {
    let result = await dataDappContract.methods
      .addReview(
        '606969f43ec3002e086b8003',
        '606969f43ec3002e086b8004',
        4,
        'Really good packet'
      )
      .send({ from: account });
    console.log(result);
  };

  //From Requester (id:...04) (pk:...0a) (a:...47)
  const pay = async () => {
    let result = await web3.eth.sendTransaction({
      from: account,
      to: '0x4eb96f705452c2808A3E3769AD3528D858127f77',
      value: '1000000000000000000'
    });
    console.log(result);
  };

  //From Owner (id:...03) (pk:...d6) (a:...8f)
  const approve = async () => {
    let result = await dataDappContract.methods
      .addPurchase(
        '606969f43ec3002e086b8003',
        '60884e9f56ff2c2b48aaa22c',
        '0x8d7a4fa5ed43b24922b59913d385a501171bb347',
        [
          'QmUr3hKzJhaG5xwk3TJ1ZWMfWw84MWXbqfj7xEKdTdLKrq',
          'Qmb1XQVqTHGp33U73SFbASoooURxBs4VtNi2N5gFksobwQ'
        ],
        '1000000000000000000',
        true
      )
      .send({ from: account });
    console.log(result);
  };

  //From Owner (id:...03) (pk:...d6) (a:...8f)
  const reject = async () => {
    let result = await dataDappContract.methods
      .addPurchase(
        '606969f43ec3002e086b8003',
        '60884e9f56ff2c2b48aaa22c',
        '0x8d7a4fa5ed43b24922b59913d385a501171bb347',
        [
          'QmUr3hKzJhaG5xwk3TJ1ZWMfWw84MWXbqfj7xEKdTdLKrq',
          'Qmb1XQVqTHGp33U73SFbASoooURxBs4VtNi2N5gFksobwQ'
        ],
        '1000000000000000000',
        false
      )
      .send({ from: account });
    console.log(result);
  };

  //From Requester (id:...04) (pk:...0a) (a:...47)
  const getKeys = async () => {
    let result = await dataDappContract.methods
      .getPurchaseKeys('606969f43ec3002e086b8004', '60884e9f56ff2c2b48aaa22c')
      .send({ from: account });
    console.log(result);
  };

  const getBalance = async () => {
    let result = await dataDappContract.methods
      .getDeposit('0xa96d413d1126bd954ebd719b6bf4f3ce226d448f')
      .send({ from: account });
    console.log(result);
  };

  return (
    <div className='App'>
      <h2>Register</h2>
      <button type='button' onClick={register1}>
        Register1
      </button>
      <button type='button' onClick={register2}>
        Register2
      </button>
      <button type='button' onClick={getRegister1UP}>
        Register1???UP
      </button>
      <button type='button' onClick={getRegister2UP}>
        Register2???UP
      </button>
      <h2>Upload</h2>
      <button type='button' onClick={upload}>
        Upload
      </button>
      <hr />
      <h2>Sample</h2>
      <button type='button' onClick={sample}>
        Sample
      </button>
      <hr />
      <h2>Purchase</h2>
      <button type='button' onClick={pay}>
        Pay
      </button>
      <button type='button' onClick={approve}>
        Approve
      </button>
      <button type='button' onClick={reject}>
        Reject
      </button>
      <button type='button' onClick={getKeys}>
        Get Keys
      </button>
      <button type='button' onClick={getBalance}>
        Get Balance
      </button>
      <hr />
      <h2>Review</h2>
      <button type='button' onClick={review}>
        Review
      </button>
    </div>
  );
};

export default App;
