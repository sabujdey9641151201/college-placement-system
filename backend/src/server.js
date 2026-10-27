require('dotenv').config();
if(!process.env.JWT_SECRET||process.env.JWT_SECRET.length<32)throw new Error('JWT_SECRET must be at least 32 characters');
const app=require('./app'),db=require('./db'),port=Number(process.env.PORT||5000);
async function start(){await db.query('SELECT 1');app.listen(port,()=>console.log(`Placement API listening on http://localhost:${port}`))}
start().catch(e=>{console.error('Unable to start API:',e.message);process.exit(1)});
