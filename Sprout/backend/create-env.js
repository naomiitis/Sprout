// create-env.js - Simple script to create .env file
// Usage: node create-env.js "mongodb_uri" "gemini_api_key"

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const args = process.argv.slice(2);

if (args.length < 2) {
  console.log('❌ Usage: node create-env.js "mongodb_uri" "gemini_api_key"');
  console.log('\nExample:');
  console.log('  node create-env.js "mongodb+srv://user:pass@cluster.mongodb.net/sprout" "AIzaSy..."');
  process.exit(1);
}

const mongoUri = args[0];
const geminiKey = args[1];
const port = args[2] || '4000';

const envContent = `# MongoDB Connection String
MONGO_URI=${mongoUri}

# Google Gemini API Key
GEMINI_API_KEY=${geminiKey}

# Server Port
PORT=${port}
`;

const envPath = path.join(__dirname, '.env');
fs.writeFileSync(envPath, envContent);

console.log('✅ Created .env file successfully!');
console.log('🚀 You can now run: npm start');

