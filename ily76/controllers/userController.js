const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

exports.createUser = async (req, res) => {
  const users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));
  const newUser = { id: uuidv4(), ...req.body };
  users.push(newUser);
  fs.writeFileSync('data/users.txt', JSON.stringify(users, null, 2));
  res.status(201).send(newUser);
};

exports.getUsers = async (req, res) => {
  const users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));
  res.send(users);
};

exports.getUserById = async (req, res) => {
  const users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));
  const user = users.find(u => u.id === req.params.id);
  if (!user) return res.status(404).send({ error: 'User not found' });
  res.send(user);
};

exports.updateUser = async (req, res) => {
  const users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));
  const index = users.findIndex(u => u.id === req.params.id);
  if (index === -1) return res.status(404).send({ error: 'User not found' });
  users[index] = { ...users[index], ...req.body };
  fs.writeFileSync('data/users.txt', JSON.stringify(users, null, 2));
  res.send(users[index]);
};

exports.deleteUser = async (req, res) => {
  let users = JSON.parse(fs.readFileSync('data/users.txt', 'utf8'));
  const index = users.findIndex(u => u.id === req.params.id);
  if (index === -1) return res.status(404).send({ error: 'User not found' });
  users = users.filter(u => u.id !== req.params.id);
  fs.writeFileSync('data/users.txt', JSON.stringify(users, null, 2));
  res.send({ message: 'User deleted' });
};
