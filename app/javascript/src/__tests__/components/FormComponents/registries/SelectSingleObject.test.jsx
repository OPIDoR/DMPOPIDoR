import {
  act,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import selectEvent from "react-select-event";
import SelectSingleObject from "../../../../components/FormComponents/registries/SelectSingleObject";

import { Wrapper } from "../../../__utils__/reactHookFormHelpers";
import Global from "../../../../components/context/GlobalContext";
import Forms from "../../../../components/context/FormsContext";
const { madmpFragment } = vi.hoisted(() => ({
  madmpFragment: {
    getAvailableRegistries: vi.fn(),
    getRegistryByName: vi.fn(),
  },
}));
vi.mock("../../../../services/index.js", () => ({ madmpFragment }));

vi.mock("react-i18next", () => ({
  // this mock makes sure any components using the translate hook can use it without a warning being shown
  useTranslation: () => ({
    t: (str) => str,
    i18n: {
      changeLanguage: () => new Promise(() => {}),
    },
  }),
  initReactI18next: {
    type: "3rdParty",
    init: () => {},
  },
}));

// Mock out all top level functions, such as get, put, delete and post:
vi.mock("axios");

const props = {
  label: "Select Single Object Label",
  propName: "mySelectSingleObject",
  tooltip: "my tooltip",
  category: "SingleRegistryCategory",
  topic: "generic",
};

const mockedRegistriesData = [
  {
    name: "SingleRegistry1",
    values: [
      {
        fr_FR: "Bonjour",
        en_GB: "Hello",
      },
    ],
  },
  {
    name: "SingleRegistry2",
    values: [
      {
        fr_FR: "Bonjour",
        en_GB: "Hello",
      },
    ],
  },
];

describe("SelectSingleObject component", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });
  test("component rendering", async () => {
    madmpFragment.getAvailableRegistries.mockResolvedValue({
      data: mockedRegistriesData[0],
    });
    await act(async () =>
      render(
        <Global>
          <Forms>
            <Wrapper propName={props.propName}>
              <SelectSingleObject {...props} />
            </Wrapper>
          </Forms>
        </Global>,
      ),
    );
    expect(screen.getByTestId("select-single-object-label")).toHaveTextContent(
      props.label,
    );
    expect(
      screen.queryByTestId("select-single-object-registry-selector"),
    ).not.toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
    expect(screen.getByTestId("select-single-object-div")).toBeInTheDocument();
    expect(screen.getByTestId("select-single-object-div")).toHaveTextContent(
      "select" + "selectOne",
    );
    expect(madmpFragment.getAvailableRegistries).toHaveBeenCalledWith(
      props.category,
      props.dataType,
      props.topic,
    );
    expect(madmpFragment.getRegistryByName).not.toHaveBeenCalled();
  });
  test("component rendering with multiple registries", async () => {
    madmpFragment.getAvailableRegistries.mockResolvedValue({
      data: mockedRegistriesData,
    });
    await act(async () =>
      render(
        <Global>
          <Forms>
            <Wrapper propName={props.propName}>
              <SelectSingleObject {...props} />
            </Wrapper>
          </Forms>
        </Global>,
      ),
    );
    expect(screen.getByTestId("select-single-object-label")).toHaveTextContent(
      props.label,
    );
    expect(
      screen.queryByTestId("select-single-object-registry-selector"),
    ).toBeInTheDocument();
    expect(screen.getByText("selectRegistry")).toBeInTheDocument();
    expect(screen.getByTestId(/tooltip_info_icon_[0-9]+/i)).toBeInTheDocument();
    expect(screen.getByTestId("select-single-object-div")).toBeInTheDocument();
    expect(screen.getByTestId("select-single-object-div")).toHaveTextContent(
      "thenSelect" + "selectOne",
    );
    expect(madmpFragment.getAvailableRegistries).toHaveBeenCalledWith(
      props.category,
      props.dataType,
      props.topic,
    );
    expect(madmpFragment.getRegistryByName).not.toHaveBeenCalled();
  });
  test("component with multiple registry should call getRegistryByName when choosing a registry", async () => {
    madmpFragment.getRegistryByName.mockResolvedValue({
      data: mockedRegistriesData[0].values,
    });
    const { findByText } = render(
      <Global>
        <Forms>
          <Wrapper propName={props.propName}>
            <SelectSingleObject {...props} />
          </Wrapper>
        </Forms>
      </Global>,
    );
    const registrySelector = await findByText("selectRegistry");
    expect(registrySelector).toBeInTheDocument();
    selectEvent.openMenu(registrySelector);

    const registry = await findByText("SingleRegistry1");
    await waitFor(() => expect(registry).toBeInTheDocument());
    fireEvent.click(registry);
    await waitFor(() =>
      expect(madmpFragment.getRegistryByName).toHaveBeenCalledWith(
        "SingleRegistry1",
      ),
    );
  });
});
