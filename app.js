const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const cors = require('cors');
const cookieParser = require('cookie-parser');

require('dotenv').config({ path: path.join(__dirname, '.env') });


const app = express();
app.use(cors());

app.options('*', cors());

app.use(bodyParser.json());
app.use(
	bodyParser.urlencoded({
		extended: true
	})
);


app.use(cookieParser());

const PORT = process.env.PORT || 3000;

app.use(`/assets`, express.static(path.resolve(__dirname, './assets')));

app.use(express.static(path.resolve(__dirname, './assets')));

// app.use(require('./helpers/authMiddleware'));

// Include all routes
require('./helpers/routes').route(app);
app.use(require(`./helpers/errorHandler`));

app.get('/', function (req, res) {
	res.send("Hello world!!")
})

app.listen(PORT, () => {
	console.log(`Server is running at port ${PORT}`);
});
