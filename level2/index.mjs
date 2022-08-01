import {loadStdlib, ask} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

if (process.argv.length < 3 || ['deployer', 'attacher'].includes(process.argv[2]) == false) {
  console.log('Usage: reach run index [deployer|attacher]');
  process.exit(0);
}

const role = process.argv[2];
console.log(`Starting as ${role}`)

const toAU = (su) => stdlib.parseCurrency(su);
const toSU = (au) => stdlib.formatCurrency(au, 4);
const iDeployerBalance = toAU(6000);
const iAttacherBalance = toAU(500)
const showBalance = async (acc) => console.log(`Your balance is ${toSU(await stdlib.balanceOf(acc))}.`);

// shared interact object.
const sharedInteract = {
  displayTime: async (time) => {
    console.log(`Time count: ${time}`)
  },
  informTimeout: async () => {
    console.log("Time out occured")
  }
}

// Deployer:
if (role == 'deployer') {
  const choiceArray = ["I'm still here", "I'm not here" ];
  const amt = await ask.ask(`How much do you want to put into the vault contract`, stdlib.parseCurrency);
  const  deployerInteract = {
    ...sharedInteract,
    ready: async () => {
      console.log(`Contract is ready...${JSON.stringify(await ctc.getInfo())}`);
  },
    inheritance: amt,
    getChoice: async () => {
      const choice = await ask.ask(
        `Are you still here?`,
        ask.yesno
      );
      console.log(`Your choice is ${choice ? choiceArray[0] : choiceArray[1]}`);
      return (choice ? true : false);
    },
    deadline: 10,

  }

  console.log("Creating a test account...")
  const deployerAcc = await stdlib.newTestAccount(iDeployerBalance);
  await showBalance(deployerAcc);
  const ctc = deployerAcc.contract(backend);
    // console.log(`Contract lauched successfully, id: ${JSON.stringify(await ctc.getInfo())}, copy and paste in another terminal.`)
  await ctc.participants.Deployer(deployerInteract);
  await showBalance(deployerAcc);
  console.log("done !!")
  process.exit(0)

} else {
  const attacherInteract = {
    ...sharedInteract,
    acceptTerms: async (num) => {
      const accept = await ask.ask(
        `do you accepts the terms of The Vault for ${stdlib.formatCurrency(num)}?`,
        ask.yesno
      );
      if (!accept) {
        process.exit(0);
      }
      return (accept ? true : false);
    }
  }

  console.log("Creating a test account...");
  const attacherAcc = await stdlib.newTestAccount(iAttacherBalance);
  await showBalance(attacherAcc);
  const info = await ask.ask('Paste contract info:', (s) => JSON.parse(s));
  const ctca = attacherAcc.contract(backend, info);
  await ctca.p.Attacher(attacherInteract);
  await showBalance(attacherAcc)
  process.exit(0)

}