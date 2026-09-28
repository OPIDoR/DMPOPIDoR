import { useContext } from "react";
import { GlobalContext } from "../../context/GlobalContext";
import { Card, Col, Row } from "react-bootstrap";
import SharedLabelLayout from "../../SharedLabel/SharedLabelLayout";

function PlanTabLayout({ children }) {
  const { planTitle, planId, clients } = useContext(GlobalContext);
  return (
    <div style={{ display: "flex", flexDirection: "column" }}>
      <Row>
        <Col md={12} style={{ textAlign: "center" }}>
          <h1>{planTitle}</h1>
        </Col>
      </Row>
      <Row>
        <Col
          md={12}
          style={{
            display: "flex",
            justifyContent: "flex-end",
            paddingRight: "30px",
          }}
        >
          <SharedLabelLayout planId={planId} clients={clients} />
        </Col>
      </Row>
      <Row id="content">
        <Card style={{ border: "none", boxShadow: "none" }}>
          <Card.Body>{children}</Card.Body>
        </Card>
      </Row>
    </div>
  );
}
export default PlanTabLayout;
