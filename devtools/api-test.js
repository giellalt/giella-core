#!/usr/bin/env node

// API Test Script
// Tests speller or grammar services for all available languages

const https = require('https');

// Parse command line arguments
const args = process.argv.slice(2);
let testWord = 'nuvviDspeller';
let apiEnv = 'prod';
let serviceType = 'speller';
let jsonOutput = false;

// Parse arguments
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--word' || args[i] === '-w') {
    testWord = args[++i];
  } else if (args[i] === '--env' || args[i] === '-e') {
    apiEnv = args[++i];
  } else if (args[i] === '--grammar' || args[i] === '-g') {
    serviceType = 'grammar';
  } else if (args[i] === '--json' || args[i] === '-j') {
    jsonOutput = true;
  } else if (args[i] === '--help' || args[i] === '-h') {
    console.log(`
Usage: ${process.argv[1]} [OPTIONS]

Options:
  -w, --word <word>     Word to test (default: nuvviDspeller)
  -e, --env <env>       Environment: prod, beta, dev (default: prod)
  -g, --grammar         Test grammar checker instead of speller
  -j, --json            Output full JSON response
  -h, --help            Show this help message

Examples:
  ${process.argv[1]}
  ${process.argv[1]} --word test --env beta
  ${process.argv[1]} -w "min tekst" -g
  ${process.argv[1]} --json
`);
    process.exit(0);
  }
}

// API base URLs
const apiUrls = {
  prod: 'api-giellalt.uit.no',
  beta: 'beta.api.giellalt.org',
  dev: 'dev.api.giellalt.org'
};

const apiHost = apiUrls[apiEnv] || apiUrls.prod;

// Function to make HTTPS GET request
function httpsGet(hostname, path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: hostname,
      path: path,
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      },
      timeout: 3000
    };

    const req = https.get(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    });
    
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Timeout - ingen respons etter 3 sekund'));
    });
    
    req.on('error', reject);
  });
}

// Function to make HTTPS POST request
function httpsPost(hostname, path, postData) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(postData);
    
    const options = {
      hostname: hostname,
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
        'Accept': 'application/json'
      },
      timeout: 3000
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(responseData));
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Timeout - ingen respons etter 3 sekund'));
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

// Main function
async function main() {
  try {
    console.log(`Testing ${serviceType} services on ${apiEnv} (${apiHost})`);
    console.log(`Test word: "${testWord}"\n`);

    // Get list of available languages
    const languages = await httpsGet(apiHost, '/languages');
    
    if (!languages.available || !languages.available[serviceType]) {
      console.error(`No ${serviceType} services available`);
      process.exit(1);
    }

    const services = languages.available[serviceType];
    const langCodes = Object.keys(services);

    if (langCodes.length === 0) {
      console.log(`No ${serviceType} services found`);
      process.exit(0);
    }

    console.log(`Found ${langCodes.length} ${serviceType} service(s)\n`);

    // Test each language
    for (const langCode of langCodes) {
      const langName = services[langCode];
      
      try {
        const endpoint = serviceType === 'speller' 
          ? `/speller/${langCode}`
          : `/grammar/${langCode}`;
        
        const requestBody = { text: testWord };
        const result = await httpsPost(apiHost, endpoint, requestBody);

        if (jsonOutput) {
          console.log(`${langCode} (${langName}):`);
          console.log(JSON.stringify(result, null, 2));
          console.log('');
        } else {
          // Compact output
          console.log(`${langCode} - ${langName}`);
          
          if (serviceType === 'speller' && result.results && result.results.length > 0) {
            const wordResult = result.results[0];
            console.log(`  ${wordResult.word} - ${wordResult.is_correct ? 'riktig' : 'feil'}`);
            
            if (wordResult.suggestions && wordResult.suggestions.length > 0) {
              wordResult.suggestions.forEach(suggestion => {
                console.log(`    ${suggestion.value}`);
              });
            } else if (!wordResult.is_correct) {
              console.log(`  (Ingen forslag tilgjengeleg)`);
            }
          } else if (serviceType === 'grammar' && result.errs) {
            if (result.errs.length === 0) {
              console.log(`  Ingen feil funne`);
            } else {
              result.errs.forEach(err => {
                console.log(`  ${err.error_text || testWord} - ${err.title || 'feil'}`);
                if (err.suggestions && err.suggestions.length > 0) {
                  err.suggestions.forEach(suggestion => {
                    console.log(`    ${suggestion}`);
                  });
                } else {
                  console.log(`  (Ingen forslag tilgjengeleg)`);
                }
              });
            }
          } else {
            console.log(`  Ukjent responsformat`);
          }
          
          console.log('');
        }
      } catch (error) {
        console.log(`${langCode} (${langName}): ERROR - ${error.message}`);
        console.log('');
      }
    }

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
