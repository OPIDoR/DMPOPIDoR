import { DriverProvider } from './DriverContext.jsx';
import Driver from './Driver.jsx';

export default (props) => (
  <DriverProvider>
    <Driver {...props} />
  </DriverProvider>
);
