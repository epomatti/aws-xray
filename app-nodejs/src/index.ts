import express from 'express'
import AWSXRay from 'aws-xray-sdk';


const app = express()
const port = process.env.PORT || 3000

AWSXRay.config([AWSXRay.plugins.EC2Plugin, AWSXRay.plugins.EC2Plugin]);
app.use(AWSXRay.express.openSegment('MyApp'));

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.get('/api/hello', (req, res) => {
  res.send('Hello!')
})

app.get('/health', (req, res) => {
  res.send('OK')
})

app.use(AWSXRay.express.closeSegment());

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})