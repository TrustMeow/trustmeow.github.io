// A simple script that shows an alert and defines a variable
alert("External script loaded successfully!");

// Define a global variable to confirm execution
window.testMessage = "Hello from the external script!";

// Define a function to call later
window.sayHello = function(name) {
  console.log(`Hello, ${name}! This came from the external script.`);
};
