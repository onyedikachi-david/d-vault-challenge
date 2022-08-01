'reach 0.1';

// Deployer should pay a large amount to the contract, say 5000
// Attacher will send a boolean to the backend to accept vault, Attacher should see the vault then
// Have a constant value for a 'countdown timer'. declared here. and show the countdown to both parties

const COUNTDOWN = 20;
const DEADLINE = 20;

const shared = {
  displayTime: Fun([UInt], Null),
  informTimeout: Fun([], Null)
}

export const main = Reach.App(() => {
  const D = Participant('Deployer', {
    ...shared,
    ready: Fun([], Null),
    inheritance: UInt,
    getChoice: Fun([], Bool),
    deadline: UInt, // time delta (blocks/rounds)
  });
  const A = Participant('Attacher', {
    ...shared,
    acceptTerms: Fun([UInt], Bool),
  });
  init();

//  D.publish()
//  commit()

  
  D.only(() => {
    const value = declassify(interact.inheritance)
    const deadline = declassify(interact.deadline);
    // interact.ready();
  })
  D.publish(value, deadline).pay(value)
  D.interact.ready();
  commit();

  A.only(() => {
    const terms = declassify(interact.acceptTerms(value))
  })
  A.publish(terms);
  commit();

  each([D, A], ()=> {
    interact.displayTime(COUNTDOWN)
  })
  D.publish()

  

  // const timeRemaining = lastConsensusTime() + COUNTDOWN
  var [timer, choice] = [20 + lastConsensusTime(), true]
  invariant(balance() == value)
  while (choice) {
    // commit()

    const informTimeout = () => {
      each([D, A], () => {
        interact.informTimeout();
        // interact.displayTime(COUNTDOWN)
      });
    };

    if (timer == lastConsensusTime()) {
      transfer(value).to(D)
      commit()
      exit()
    } else {
      commit()
      D.only(()=> {
        const option = declassify(interact.getChoice())
      })
      D.publish(option).timeout(relativeTime(deadline), () => closeTo(A, informTimeout));
    [timer, choice] = [timer - 1, option];
    continue;
    }
   

    // [timer, choice] = [timer - lastConsensusTime(), option];
    // continue;
  }
  // if (option) {
  //   transfer(value).to(D)
  // } else {
    transfer(value).to(A)
  // }
  commit()
  
  exit();
});
