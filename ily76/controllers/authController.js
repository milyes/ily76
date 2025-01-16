const jwt = require('jsonwebtoken');
const fs = require('fs');
const bcrypt = require('bcrypt');

exports.login = async (req, res) => {
  const { email, password } = req.body;
  const users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));

  const user = users.find(u => u.email === email);

  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).send({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ userId: user.id }, 'secret_key');
  res.send({ token });
};
