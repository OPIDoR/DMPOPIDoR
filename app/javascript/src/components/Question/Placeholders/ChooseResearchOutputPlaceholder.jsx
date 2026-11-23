import Card from "react-bootstrap/Card";
import Placeholder from "react-bootstrap/Placeholder";

function ChooseResearchOutputPlaceholder() {
  return (
    <Placeholder as="div" animation="wave">
      <Placeholder
        as={Card}
        style={{ margin: "10px", height: "50px", width: "100%" }}
      />
    </Placeholder>
  );
}

export default ChooseResearchOutputPlaceholder;
