import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const accAttacher = await stdlib.newTestAccount(startingBalance);
const accDeployer = await stdlib.newTestAccount(stdlib.parseCurrency(6000))
console.log('Hello, Alice and Bob!');

const bal = async (who) => { return stdlib.formatCurrency((await stdlib.balanceOf(who)))}
console.log(`Deployer's balance before: ${await bal(accDeployer)}`)
console.log(`Attacher's balance before: ${await bal(accAttacher)}`)

console.log('Launching...');
const ctcDeployer = accDeployer.contract(backend);
const ctcAttacher = accAttacher.contract(backend, ctcDeployer.getInfo());

const choiceArray = ["I'm here", "I'm not here"]
const shared = {
  displayTime: (time) => {
    console.log(`Count down time: ${time}`)
  }
}
console.log('Starting backends...');
await Promise.all([
  backend.Deployer(ctcDeployer, {
    ...shared,
    inheritance: stdlib.parseCurrency(5000),
    getChoice: () => {
      const choice = Math.floor(Math.random() * 2)
      console.log(`Deployer decision is ${choiceArray[choice]}`)
      return (choice == 1 ? false : true)
    }
  }),
  backend.Attacher(ctcAttacher, {
    ...shared,
    acceptTerms: (amt) => {
      console.log(`Accepts vaults of: ${amt}`)
      return true
    }
  }),
]);
console.log(`Deployer's balance after: ${await bal(accDeployer)}`)
console.log(`Attacher's balance after: ${await bal(accAttacher)}`)
console.log('Goodbye, Alice and Bob!');
