const fs = require('fs');
const readline = require('readline');

async function extractTests() {
    // Path to the file where test results will be stored
    let testsFile = __dirname + '/testsToRun.txt';

    // By default, we assume no specific tests are requested, so write 'null'
    await fs.promises.writeFile(testsFile, 'null');

    const lines = readline.createInterface({
        input: fs.createReadStream(__dirname + '/pr_body.txt'),
        crlfDelay: Infinity
    });

    let hasTests = false;

    for await (const line of lines) {
        // Check for the special delimiter 'Apex::[ ... ]::Apex'
        if (line.includes('Apex::[') && line.includes(']::Apex')) {
            let tests = line.substring(line.indexOf('Apex::[') + 7, line.indexOf(']::Apex'));
            
            // If tests were found, overwrite the default 'null'
            await fs.promises.writeFile(testsFile, tests);
            hasTests = true;
        }
    }

    // If no tests were found, 'null' will remain in the file
    if (!hasTests) {
        await fs.promises.writeFile(testsFile, 'null');
    }
}

extractTests();
