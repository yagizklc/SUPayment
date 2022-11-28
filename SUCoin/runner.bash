#!/node_modules/.bin/ganache

npx truffle migrate --network development --compile
npx truffle exec --network development ./scripts/index.js
