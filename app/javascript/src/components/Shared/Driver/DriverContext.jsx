import { createContext, useState, useContext } from 'react';

export const DriverContext = createContext();

export const DriverProvider = ({ children }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <DriverContext.Provider value={{ isOpen, setIsOpen }}>
      {children}
    </DriverContext.Provider>
  );
};

export const useTour = () => {
  const context = useContext(DriverContext);
  if (!context) {
    throw new Error('useTour must be used within a DriverContext');
  }
  return context;
};
