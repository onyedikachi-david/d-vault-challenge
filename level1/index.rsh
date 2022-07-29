'reach 0.1';

// Deployer should pay a large amount to the contract, say 5000
// Attacher will send a boolean to the backend to accept vault, Attacher should see the vault then
// Have a constant value for a 'countdown timer'. declared here. and show the countdown to both parties

const COUNTDOWN = 10;

const shared = {
  displayTime: Fun([UInt], Null)
}

export const main = Reach.App(() => {
  const D = Participant('Deployer', {
    ...shared,
    inheritance: UInt,
    getChoice: Fun([Null], Bool)
  });
  const A = Participant('Attacher', {
    ...shared,
    acceptTerms: Fun([UInt], Bool),
  });
  init();
  
  D.only(() => {
    const value = declassify(interact.inheritance)
  })
  D.publish(value).pay(value)
  commit();

  A.only(() => {
    const terms = declassify(interact.acceptTerms(value))
  })
  A.publish(terms);
  commit();

  each([D, A], ()=> {
    interact.displayTime(COUNTDOWN)
  })

  D.only(()=> {
    const option = declassify(interact.getChoice(null))
  })
  D.publish(option)
  if (option) {
    transfer(value).to(D)
  } else {
    transfer(value).to(A)
  }
  commit()
  
  exit();
});
