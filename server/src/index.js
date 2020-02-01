var koa = require('koa');
var app = module.exports = new koa();
const server = require('http').createServer(app.callback());
const WebSocket = require('ws');
const wss = new WebSocket.Server({server});
const Router = require('koa-router');
const cors = require('@koa/cors');
const bodyParser = require('koa-bodyparser');

app.use(bodyParser());

app.use(cors());

app.use(middleware);

function middleware(ctx, next) {
  const start = new Date();
  return next().then(() => {
    const ms = new Date() - start;
    console.log(`${start.toLocaleTimeString()} ${ctx.request.method} ${ctx.request.url} ${ctx.response.status} - ${ms}ms`);
  });
}

const getRandomInt = (min, max) => {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min;
};

const recipeNames = ['Blini', 'Salted Herring', 'Pickled Vegetables', 'Medovik', 'Solyanka Soup', 'Olivier Salad'];
const details = ['Known as Russian salad around the world',
  'Probably the most famous traditional Russian/Ukrainian dish internationally',
  'Another Russian dish to receive global recognition',
  'Another soup on the list to warm you during the six to eight months of cold'
];
const types = ['beginner', 'advanced', 'medium', 'new', 'promo'];
const recipes = [];

for (let i = 0; i < 10; i++) {
  recipes.push({
    id: i + 1,
    name: recipeNames[getRandomInt(0, recipeNames.length)],
    details: details[getRandomInt(0, details.length)],
    time: getRandomInt(500, 1000),
    type: types[getRandomInt(0, types.length)],
    rating: getRandomInt(0, 10)
  });
}

const router = new Router();
router.get('/types', ctx => {
  ctx.response.body = types;
  ctx.response.status = 200;
});

router.get('/recipes/:type', ctx => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.params;
  const type = headers.type;
  // console.log("type: " + JSON.stringify(type));
  ctx.response.body = recipes.filter(recipe => recipe.type == type);
  // console.log("type: " + JSON.stringify(type) + "body: " + JSON.stringify(ctx.response.body));
  ctx.response.status = 200;
});

router.get('/low', ctx => {
  ctx.response.body = recipes;
  // console.log("low: " + JSON.stringify(recipes));
  ctx.response.status = 200;
});

router.post('/increment', ctx => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.request.body;
  // console.log("body: " + JSON.stringify(headers));
  const id = headers.id;
  if (typeof id !== 'undefined') {
    const index = recipes.findIndex(recipe => recipe.id == id);
    if (index === -1) {
      console.log("Recipe not available!");
      ctx.response.body = {text: 'Recipe not available!'};
      ctx.response.status = 404;
    } else {
      let recipe = recipes[index];
      recipe.rating++;
      // console.log("incremented: " + JSON.stringify(recipe));
      ctx.response.body = recipe;
      ctx.response.status = 200;
    }
  } else {
    console.log("Missing or invalid: id!");
    ctx.response.body = {text: 'Missing or invalid: id!'};
    ctx.response.status = 404;
  }
});

const broadcast = (data) =>
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });

router.post('/recipe', ctx => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.request.body;
  // console.log("body: " + JSON.stringify(headers));
  const name = headers.name;
  const details = headers.details;
  const time = headers.time;
  const type = headers.type;
  const rating = headers.rating;
  if (typeof name !== 'undefined' && typeof details !== 'undefined' && typeof time !== 'undefined'
    && typeof type !== 'undefined' && rating !== 'undefined') {
    const index = recipes.findIndex(recipe => recipe.name == name);
    if (index !== -1) {
      console.log("Recipe already exists!");
      ctx.response.body = {text: 'Recipe already exists!'};
      ctx.response.status = 404;
    } else {
      let maxId = Math.max.apply(Math, recipes.map(function (recipe) {
        return recipe.id;
      })) + 1;
      let recipe = {
        id: maxId,
        name,
        details,
        time,
        type,
        rating
      };
      // console.log("created: " + JSON.stringify(recipe));
      recipes.push(recipe);
      broadcast(recipe);
      ctx.response.body = recipe;
      ctx.response.status = 200;
    }
  } else {
    console.log("Missing or invalid fields!");
    ctx.response.body = {text: 'Missing or invalid fields!'};
    ctx.response.status = 404;
  }
});

router.del('/recipe/:id', ctx => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.params;
  // console.log("body: " + JSON.stringify(headers));
  const id = headers.id;
  if (typeof id !== 'undefined') {
    const index = recipes.findIndex(recipe => recipe.id == id);
    if (index === -1) {
      console.log("No recipe with id: " + id);
      ctx.response.body = {text: 'Invalid recipe id'};
      ctx.response.status = 404;
    } else {
      let recipe = recipes[index];
      // console.log("deleted: " + JSON.stringify(recipe));
      recipes.splice(index, 1);
      ctx.response.body = recipe;
      ctx.response.status = 200;
    }
  } else {
    ctx.response.body = {text: 'Id missing or invalid'};
    ctx.response.status = 404;
  }
});


app.use(router.routes());
app.use(router.allowedMethods());

server.listen(2201);