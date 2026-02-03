import axios from 'axios';

const client = axios.create({
  baseURL: '/',
  headers: {
    'Content-Type': 'application/json',
  },
});

export default client;
