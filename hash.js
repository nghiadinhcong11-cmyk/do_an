const bcrypt = require("bcryptjs");

const hash = bcrypt.hashSync("123456", 11);
console.log(hash);