"""MEDUSA full-stack entry point."""

import from src.medusa {
    ApproveProposal,
    CreateProject,
    LoadWorkspace,
    ProposeChange,
    ResetDemo,
}

cl {
    import from .ui { MedusaApp }

    def:pub app -> JsxElement {
        return <MedusaApp />;
    }
}
