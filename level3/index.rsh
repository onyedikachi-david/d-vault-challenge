'reach 0.1';

// Deployer should pay a large amount to the contract, say 5000
// Attacher will send a boolean to the backend to accept vault, Attacher should see the vault then
// Have a constant value for a 'countdown timer'. declared here. and show the countdown to both parties

const COUNTDOWN = 10;
const DEADLINE = 20;

const shared = {
  displayTime: Fun([UInt], Null),
  informTimeout: Fun([], Null)
}

export const main = Reach.App(() => {
  const D = Participant('Deployer', {
    ...shared,
    inheritance: UInt,
    // inToken: Token,
    getParams: Fun([], Object({
      name: Bytes(32), symbol: Bytes(8),
      url: Bytes(96), metadata: Bytes(32),
      supply: UInt,
      amt: UInt,
    })),
    getChoice: Fun([Null], Bool)
  });
  const A = API('Attacher', {
    ...shared,
    acceptTerms: Fun([UInt], Bool),
  });
  init();

  const informTimeout = () => {
    each([D, A], () => {
      interact.informTimeout();
    });
  };

  
  D.only(() => {
    const value = declassify(interact.inheritance)
    // const tokenId = declassify(interact.inToken)
    const { name, symbol, url, metadata, supply, amt } = declassify(interact.getParams());
    // return [value, tokenId]
  })
  D.publish(value, name, symbol, url, metadata, supply, amt)
  require(4 * amt <= supply);
  require(4 * amt <= UInt.max);
  const md1 = {name, symbol, url, metadata, supply};
  const tok1 = new Token(md1);
  commit();
  D.pay([[value, tok1]])


  // Make this an api call, 
  // and store it in a map
  // A.only(() => {
  //   const terms = declassify(interact.acceptTerms(value))
  // })
  // A.publish(terms);
  const [[], k] = call(acceptTerms).
  commit();

  each([D, A], ()=> {
    interact.displayTime(COUNTDOWN)
  })
  D.publish()

  

  const timeRemaining = lastConsensusTime() + COUNTDOWN
  var [timer, choice] = [timeRemaining, true]
  invariant(balance() == value)
  while (choice) {
    // commit()

    if (timer == 0) {
      transfer(value).to(D)
      commit()
      exit()
    } else {
      commit()
      D.only(()=> {
        const option = declassify(interact.getChoice(null))
      })
      D.publish(option).timeout(relativeTime(DEADLINE), () => closeTo(A, informTimeout));
    [timer, choice] = [timer - lastConsensusTime(), option];
    continue;
    }
   

    // [timer, choice] = [timer - lastConsensusTime(), option];
    // continue;
  }
  // if (option) {
  //   transfer(value).to(D)
  // } else {

  //make this an api call too to transfer to everyone.
    transfer(value).to(A)
  // }
  commit()
  
  exit();
});
