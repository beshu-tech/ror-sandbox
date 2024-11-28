// Import and start the Elastic APM agent at the very top of your application
var apm = require('elastic-apm-node').start({
    // Set custom APM Server URL (default: http://localhost:8200)
    serverUrl: 'http://apm-server:8200',
    
    // Set service name, environment, and other configurations
    serviceName: 'elastic-apm-example',
    environment: 'development'
  });
  
  const express = require('express');
  const app = express();
  
  // Sample route that triggers some APM instrumentation
  app.get('/', (req, res) => {
    // Start a custom transaction
    const transaction = apm.startTransaction('MyCustomTransaction', 'custom');
  
    // Simulate some processing
    setTimeout(() => {
      // End the transaction
      transaction.end();
      
      res.send('Hello World!');
    }, 1000);
  });
  
  // Another route to simulate an error
  app.get('/error', (req, res) => {
    // Capture an error
    apm.captureError(new Error('Something went wrong!'));
  
    res.status(500).send('Internal Server Error');
  });
  
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
  