const SUCoin = artifacts.require("SUCoin");
const TokenReceiver = artifacts.require("TokenReceiver");

const deploy = async (deployer) => {
    await deployer.deploy(SUCoin);
    await deployer.deploy(TokenReceiver);

    const suCoin = await SUCoin.deployed();
    const tokenReceiver = await TokenReceiver.deployed();

}
