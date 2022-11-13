const express = require('express');
const mongoose = require('mongoose');
const cors = require("cors");
const http = require('http');
const jwt = require("jsonwebtoken");
const Document = require("./models/document");

const authRouter = require('./routes/auth');
const documentRouter = require('./routes/document');

const PORT = process.env.PORT | 3001;

const app = express();

var server = http.createServer(app);
var io = require('socket.io')(server);

app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);

const DB = "mongodb+srv://kzi:Huy219430@cluster0.2zpizdm.mongodb.net/?retryWrites=true&w=majority";

mongoose.connect(DB).then(() => {
  console.log('Connection succesful!');
})
  .catch((err) => {
    console.log(err);
  });

io.on('connection', (socket) => {
  socket.on('join', (documentId) => {
    socket.join(documentId);
    console.log("Joined room successfully!");
  });

  socket.on('typing', (data) => {
    socket.broadcast.to(data.room).emit("changes", data);
  });

  socket.on('save', (data) => {
    saveData(data);
  })
})

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Connected at port ${PORT}`);
});

const saveData = async (data) => {
  let document = await Document.findById(data.room);
  document.content = data.delta;
  document = await document.save();
}