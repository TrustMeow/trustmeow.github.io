// Function to trigger a file download
function downloadFile(filename, content) {
    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

// Create and download "result.txt" with "Test successful"
downloadFile('result.txt', 'Test successful');

// Optional: Log success
console.log('File download initiated! Check your downloads folder.');
