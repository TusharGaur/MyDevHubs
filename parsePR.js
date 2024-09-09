const fs = require('fs');
const readline = require('readline');

async function extractTests() {
    // by default, specify that all tests should run
    let testsFile = __dirname + '/testsToRun.txt';
    await fs.promises.writeFile(testsFile, 'null'); // default to null if no tests are found

    const lines = readline.createInterface({
        input: fs.createReadStream(__dirname + '/pr_body.txt'),
        crlfDelay: Infinity
    });

    let hasTests = false;

    for await (const line of lines) {
        // special delimiter for apex tests
        if (line.includes('Apex::[') && line.includes(']::Apex')) {
            let tests = line.substring(7, line.length - 7);
            await fs.promises.writeFile(testsFile, tests);
            await fs.promises.appendFile(testsFile, '\n');
            hasTests = true;
        }
    }

    // If no tests found in the PR body, write 'null' to the file
    if (!hasTests) {
        await fs.promises.writeFile(testsFile, 'null');
    }
}

extractTests();
