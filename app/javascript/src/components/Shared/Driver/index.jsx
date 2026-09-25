import { DriverProvider } from "./DriverContext.jsx";
import Driver from "./Driver.jsx";

const DriverComponent = (props) => (
  <DriverProvider>
    <Driver {...props} />
  </DriverProvider>
);

export default DriverComponent;
