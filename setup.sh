#!/bin/bash

echo "Initialisation du projet..."

# Naviguer dans le répertoire ily76
cd ily76 || exit

# Créer le fichier package.json
echo "Création du fichier package.json..."
cat > package.json <<EOL
{
  "name": "ily76",
  "version": "1.0.0",
  "description": "Projet backend",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.17.1",
    "jsonwebtoken": "^8.5.1",
    "bcrypt": "^5.0.1",
    "fs": "0.0.1-security",
    "uuid": "^8.3.2"
  }
}
EOL

# Installer les dépendances npm
echo "Installation des dépendances npm..."
npm install

# Vérifier et créer les répertoires nécessaires
echo "Vérification des répertoires..."
mkdir -p controllers models routes middleware data

# Créer les fichiers nécessaires avec des contenus complets
echo "Création des fichiers nécessaires..."

cat > controllers/authController.js <<EOL
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
EOL

cat > controllers/userController.js <<EOL
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
EOL

cat > routes/authRoutes.js <<EOL
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/login', authController.login);

module.exports = router;
EOL

cat > routes/userRoutes.js <<EOL
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/users', authMiddleware, userController.createUser);
router.get('/users', authMiddleware, userController.getUsers);
router.get('/users/:id', authMiddleware, userController.getUserById);
router.put('/users/:id', authMiddleware, userController.updateUser);
router.delete('/users/:id', authMiddleware, userController.deleteUser);

module.exports = router;
EOL

cat > middleware/authMiddleware.js <<EOL
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(401).send({ error: 'No token provided' });
  }

  jwt.verify(token, 'secret_key', (err, decoded) => {
    if (err) {
      return res.status(401).send({ error: 'Failed to authenticate token' });
    }

    req.userId = decoded.userId;
    next();
  });
};
EOL

cat > middleware/errorHandler.js <<EOL
module.exports = (err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send({ error: 'Something went wrong!' });
};
EOL

cat > data/users.txt <<EOL
[]
EOL

cat > index.js <<EOL
const express = require('express');
const userRoutes = require('./routes/userRoutes');
const authRoutes = require('./routes/authRoutes');
const errorHandler = require('./middleware/errorHandler');

const app = express();
app.use(express.json());
app.use('/api', userRoutes);
app.use('/auth', authRoutes);

// Ajouter une route pour la racine
app.get('/', (req, res) => {
  res.send('Bienvenue à MonProjet API!');
});

app.use(errorHandler);

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
EOL

echo "Initialisation terminée. Votre projet est prêt à être déployé."

# Lancer l'application
npm start
