"""Development launch shim for Jac's root-scoped client toolchain."""

import from src.medusa {
    ApproveProposal,
    CreateProject,
    LoadWorkspace,
    ProposeChange,
    ResetDemo,
}

cl {
    import from .src.ui { MedusaApp }

    def:pub app -> JsxElement {
        return <MedusaApp />;
    }
}
