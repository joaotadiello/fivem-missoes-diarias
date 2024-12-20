import React from 'react';
import ReactDOM from 'react-dom/client';
import GlobalStyled from './style/GlobalStyle';
import './main.css'
import App from './components/App';

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <GlobalStyled />
        <App />
    </React.StrictMode>
);
