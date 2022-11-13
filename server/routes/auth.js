const express = require("express");
const jwt = require("jsonwebtoken");
const auth = require("../middlewares/auth");
const User = require("../models/user");

const authRouter = express.Router();

authRouter.get('/', auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ user, token: req.token });
});

authRouter.post('/api/signup', async (req, res) => {
    try {
        const {
            displayName,
            email,
            photoUrl,
        } = req.body;

        let user = await User.findOne({
            email: email,
        })

        if (!user) {
            user = new User({
                displayName: displayName,
                email: email,
                photoUrl: photoUrl,
            });
            user = await user.save();
        }

        const token = jwt.sign({ id: user._id }, "passwordKey");

        res.json({ user, token });

    } catch (e) {
        res.status(500).json({ errors: e.message });
    }
});

module.exports = authRouter;