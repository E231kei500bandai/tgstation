import { type Antagonist, Category } from '../base';

const Revenant: Antagonist = {
  key: 'revenant',
  name: 'Revenant',
  description: [
    `
      Become a malevolent spectral parasite. Amplify the chaos caused by other threats,
      tether to the living, briefly possess the dead, and feed on the essence of their
      dying victims to power your ghostly disruptions.
    `,
  ],
  category: Category.Midround,
};

export default Revenant;
