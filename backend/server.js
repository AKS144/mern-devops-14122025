const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const client = require('prom-client');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// --- Prometheus Metrics ---
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// --- DB Connection ---
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000
    });
    console.log('MongoDB Connected Locally');
  } catch (err) {
    console.error('MongoDB Error:', err.message);
    setTimeout(connectDB, 5000);
  }
};
connectDB();

// --- Schema & Routes ---
const TaskSchema = new mongoose.Schema({ name: String });
const Task = mongoose.model('Task', TaskSchema);

app.get('/tasks', async (req, res) => {
  const tasks = await Task.find();
  res.json(tasks);
});

app.post('/tasks', async (req, res) => {
  const newTask = new Task({ name: req.body.name });
  await newTask.save();
  res.json(newTask);
});



// UPDATE task
app.put('/tasks/:id', async (req, res) => {
  const updated = await Task.findByIdAndUpdate(
    req.params.id,
    { name: req.body.name },
    { new: true }
  );
  res.json(updated);
});

// DELETE task
app.delete('/tasks/:id', async (req, res) => {
  await Task.findByIdAndDelete(req.params.id);
  res.json({ message: "Task deleted" });
});



app.listen(5000, () => console.log(`Server running on port 5000`));