const fs = require('fs');
const path = require('path');

// Paths to the files
const userConfigPath = path.join(__dirname, 'user_config.json');
const dbJsonPath = path.join(__dirname, 'mockup-server', 'db.json');

// Read the user config file
try {
  console.log('Reading user configuration...');
  const userConfig = JSON.parse(fs.readFileSync(userConfigPath, 'utf8'));
  
  // Read the current db.json
  console.log('Reading current database...');
  const dbJson = JSON.parse(fs.readFileSync(dbJsonPath, 'utf8'));
  
  // Update the users in db.json
  console.log('Updating users in database...');
  
  // Create a copy of users without passwords for db.json
  const dbUsers = userConfig.users.map(user => {
    // Create a new object without the password field
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  });
  
  // Replace the users in db.json
  dbJson.users = dbUsers;
  
  // Write the updated db.json back to file
  console.log('Writing updated database...');
  fs.writeFileSync(dbJsonPath, JSON.stringify(dbJson, null, 2), 'utf8');
  
  console.log('Database updated successfully!');
} catch (error) {
  console.error('Error updating database:', error);
}
