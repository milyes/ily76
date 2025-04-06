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
