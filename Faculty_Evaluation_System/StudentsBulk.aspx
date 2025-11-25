<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="StudentsBulk.aspx.vb" Inherits="Faculty_Evaluation_System.StudentsBulk" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Management - Faculty Evaluation System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --primary: #1a3a8f;
            --primary-light: #2a4aaf;
            --primary-dark: #0f2259;
            --gold: #d4af37;
            --gold-light: #e6c158;
            --gold-dark: #b8941f;
            --secondary: #6c757d;
            --success: #28a745;
            --info: #17a2b8;
            --warning: #ffc107;
            --danger: #dc3545;
            --light: #f8f9fa;
            --dark: #343a40;
        }
        
        body {
            background-color: #f8f9fc;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        /* Button styling consistent with Students.aspx */
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .btn-success {
            background-color: var(--success);
            border-color: var(--success);
        }
        
        .btn-danger {
            background-color: var(--danger);
            border-color: var(--danger);
        }
        
        .btn-warning {
            background-color: var(--gold);
            border-color: var(--gold);
            color: #333;
        }
        
        .btn-warning:hover {
            background-color: var(--gold-dark);
            border-color: var(--gold-dark);
            color: #333;
        }
        
        .btn-outline-primary {
            color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary);
            border-color: var(--primary);
            color: white;
        }
        
        .btn-outline-secondary {
            color: var(--secondary);
            border-color: var(--secondary);
        }
        
        .btn-outline-secondary:hover {
            background-color: var(--secondary);
            border-color: var(--secondary);
            color: white;
        }
        
        /* Form controls consistent with Students.aspx */
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.2rem rgba(26, 58, 143, 0.25);
        }
        
        /* Table styling consistent with Students.aspx */
        .table th {
            border-top: none;
            font-weight: 700;
            color: var(--dark);
            background-color: #f8f9fc;
        }
        
        .table-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            border: none;
        }
        
        .bg-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%) !important;
            border: none;
        }
        
        .bg-light {
            background-color: #f8f9fc !important;
            border: 1px solid #e3e6f0;
        }
        
        .border {
            border: 1px solid #e3e6f0 !important;
        }
        
        .text-primary {
            color: var(--primary) !important;
        }
        
        /* Badge styling consistent with Students.aspx */
        .badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.35rem 0.65rem;
        }
        
        .badge.bg-primary {
            background-color: var(--primary) !important;
        }
        
        .badge.bg-secondary {
            background-color: var(--secondary) !important;
        }
        
        .badge.bg-success {
            background-color: var(--success) !important;
        }
        
        .badge.bg-warning {
            background-color: var(--warning) !important;
            color: #333 !important;
        }
        
        .selected-row {
            background-color: #e7f1ff !important;
            border-left: 3px solid var(--gold) !important;
        }
        
        /* Status styling consistent with Students.aspx */
        .status-active { 
            color: var(--success);
            font-weight: 600;
        }
        .status-inactive { 
            color: var(--danger);
            font-weight: 600;
        }
        .status-graduated { 
            color: var(--primary);
            font-weight: 600;
        }
        
        .action-buttons .btn {
            margin-right: 5px;
        }
        
        /* Page title consistent with Students.aspx */
        .page-title {
            color: var(--primary);
            border-bottom: 2px solid var(--gold);
            padding-bottom: 0.5rem;
        }
        
        /* Card header consistent with Students.aspx */
        .card-header {
            background-color: #f8f9fc;
            border-bottom: 1px solid #e3e6f0;
            padding: 0.75rem 1.25rem;
            font-weight: 700;
            color: var(--primary);
        }
        
        /* Alert styling consistent with Students.aspx */
        .alert-success {
            border-left: 4px solid var(--success);
        }
        
        .alert-danger {
            border-left: 4px solid var(--danger);
        }
        
        .alert-warning {
            border-left: 4px solid var(--warning);
        }
        
        .alert-info {
            border-left: 4px solid var(--info);
        }
        
        /* Hover effects */
        .table-hover tbody tr:hover {
            background-color: rgba(26, 58, 143, 0.05);
            transform: translateY(-1px);
            transition: all 0.2s ease;
        }
        
        .btn {
            transition: all 0.3s ease;
        }
        
        /* Custom gold accents consistent with Students.aspx */
        .gold-accent {
            color: var(--gold);
        }
        
        .border-gold {
            border-color: var(--gold) !important;
        }
        
        /* Card styling consistent with Students.aspx */
        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.1);
            margin-bottom: 1.5rem;
        }
        
        /* Animation for alerts consistent with Students.aspx */
        .alert-slide {
            animation: slideIn 0.5s forwards;
        }
        
        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        /* Golden West specific styling */
        .gold-accent {
            color: var(--gold);
        }
        
        /* Form section styling consistent with Students.aspx */
        .form-section {
            background-color: #f8f9fc;
            border-radius: 0.35rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .form-section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #e3e6f0;
        }
        
        @media (max-width: 768px) {
            .mobile-stack {
                flex-direction: column;
            }
            
            .mobile-stack > div {
                margin-bottom: 10px;
                width: 100%;
            }
            
            .action-buttons .btn {
                width: 100%;
                margin-bottom: 5px;
            }
            
            .page-title {
                font-size: 1.5rem;
            }
            
            .table-responsive {
                font-size: 0.875rem;
            }
            
            .btn {
                padding: 0.5rem 0.75rem;
            }
        }

        /* Additional consistent styling */
        .bg-gradient-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%) !important;
        }
        
        .text-gold {
            color: var(--gold) !important;
        }
        /* Student Type badge styling */
.badge {
    font-size: 0.75rem;
    font-weight: 600;
    padding: 0.35rem 0.65rem;
}

.bg-primary {
    background-color: var(--primary) !important;
}

.bg-warning {
    background-color: var(--warning) !important;
    color: #333 !important;
}

.bg-secondary {
    background-color: var(--secondary) !important;
}
    </style>
</head>
<body>
    <form id="form1" runat="server" class="container-fluid mt-3">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <asp:Button ID="btnBack" runat="server" Text="← Back to Students" 
                    CssClass="btn btn-outline-secondary" OnClick="btnBack_Click" />
                <h2 class="d-inline-block ms-2 mb-0 page-title"><i class="fas fa-users me-2 gold-accent"></i>Student Management</h2>
            </div>
            <div class="text-end">
              
                <asp:Label ID="lblTotalRecords" runat="server" CssClass="badge bg-secondary fs-6 ms-1"></asp:Label>
            </div>
        </div>

        <!-- Search and Filters -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0 text-primary"><i class="fas fa-search gold-accent me-2"></i>Search and Filters</h5>
            </div>
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3 col-sm-6">
                        <label class="form-label">Department</label>
                        <asp:DropDownList ID="ddlFilterDept" runat="server" CssClass="form-select">
                            <asp:ListItem Text="All Departments" Value=""></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-2 col-sm-6">
                        <label class="form-label">Year Level</label>
                        <asp:DropDownList ID="ddlFilterYearLevel" runat="server" CssClass="form-select">
                            <asp:ListItem Text="All Years" Value=""></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-2 col-sm-6">
                        <label class="form-label">Status</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select">
                            <asp:ListItem Text="All Status" Value=""></asp:ListItem>
                            <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                            <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                            <asp:ListItem Text="Graduated" Value="Graduated"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 col-sm-6">
                        <div class="input-group">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search students..." />
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-secondary" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                    <div class="col-md-2 col-sm-12 mobile-stack">
                        <asp:Button ID="btnApplyFilters" runat="server" Text="Apply" 
                            CssClass="btn btn-primary w-100" OnClick="btnApplyFilters_Click" />
                        <asp:Button ID="btnClearFilters" runat="server" Text="Clear" 
                            CssClass="btn btn-outline-secondary w-100 mt-2" OnClick="btnClearFilters_Click" />
                    </div>
                </div>
                <div class="col-md-2 col-sm-6">
    <label class="form-label">Student Type</label>
    <asp:DropDownList ID="ddlFilterStudentType" runat="server" CssClass="form-select">
        <asp:ListItem Text="All Types" Value=""></asp:ListItem>
        <asp:ListItem Text="Regular" Value="Regular"></asp:ListItem>
        <asp:ListItem Text="Irregular" Value="Irregular"></asp:ListItem>
    </asp:DropDownList>
</div>
            </div>
        </div>

        <!-- Bulk Actions -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0 text-primary"><i class="fas fa-users-cog gold-accent me-2"></i>Batch Operations</h5>
            </div>
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label">Year Level</label>
                        <asp:DropDownList ID="ddlYearLevel" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Select Year Level" Value=""></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Section</label>
                        <asp:TextBox ID="txtSection" runat="server" CssClass="form-control" placeholder="Enter section"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Status</label>
                        <asp:DropDownList ID="ddlNewStatus" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Select Status" Value=""></asp:ListItem>
                            <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                            <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                            <asp:ListItem Text="Graduated" Value="Graduated"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3 mobile-stack">
                        <asp:Button ID="btnBulkUpdate" runat="server" Text="Update Selected" 
                            CssClass="btn btn-success" OnClick="btnBulkUpdate_Click" 
                            OnClientClick="return validateBulkUpdate();" />
                        <asp:Button ID="btnBulkDelete" runat="server" Text="Delete Selected" 
                            CssClass="btn btn-danger mt-2" OnClick="btnBulkDelete_Click"
                            OnClientClick="return confirm('WARNING: This will permanently delete selected students. This action cannot be undone. Continue?');" />
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-12">
                        <asp:Button ID="btnSelectAll" runat="server" Text="Select All" 
                            CssClass="btn btn-outline-primary" OnClick="btnSelectAll_Click" />
                        <asp:Button ID="btnDeselectAll" runat="server" Text="Clear All" 
                            CssClass="btn btn-outline-secondary" OnClick="btnDeselectAll_Click" />
                    </div>
                </div>
                <div class="col-md-3">
    <label class="form-label">Student Type</label>
    <asp:DropDownList ID="ddlNewStudentType" runat="server" CssClass="form-select">
        <asp:ListItem Text="Select Type" Value=""></asp:ListItem>
        <asp:ListItem Text="Regular" Value="Regular"></asp:ListItem>
        <asp:ListItem Text="Irregular" Value="Irregular"></asp:ListItem>
    </asp:DropDownList>
</div>
            </div>
        </div>

        <!-- Students Grid -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0 text-primary"><i class="fas fa-users me-2 gold-accent"></i>Student Records</h5>
                <div>
                    <span class="badge bg-light text-dark">
                        <i class="fas fa-users me-1"></i>
                        <span id="totalStudents" runat="server">0</span> Total
                    </span>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive" style="max-height: 600px; overflow-y: auto;">
                    <asp:GridView ID="gvStudentsBulk" runat="server" AutoGenerateColumns="False" 
                        CssClass="table table-bordered table-hover mb-0" DataKeyNames="StudentID"
                        AllowPaging="true" PageSize="50" OnPageIndexChanging="gvStudentsBulk_PageIndexChanging"
                        OnRowDataBound="gvStudentsBulk_RowDataBound" EmptyDataText="No students found matching your criteria."
                        EnableViewState="true" ShowHeaderWhenEmpty="true"
                        OnRowCommand="gvStudentsBulk_RowCommand" OnRowEditing="gvStudentsBulk_RowEditing"
                        OnRowUpdating="gvStudentsBulk_RowUpdating" OnRowCancelingEdit="gvStudentsBulk_RowCancelingEdit">
                        <Columns>
                            <asp:TemplateField HeaderText="Select" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" ItemStyle-Width="50">
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkSelect" runat="server" CssClass="form-check-input row-checkbox" 
                                        Checked='<%# IsStudentSelected(Container.DataItem) %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="StudentID" HeaderText="ID" ReadOnly="True" Visible="false" />
                            <asp:BoundField DataField="FullName" HeaderText="Full Name" ReadOnly="true" />
                            <asp:BoundField DataField="SchoolID" HeaderText="School ID" ReadOnly="true" />
                            <asp:BoundField DataField="DepartmentName" HeaderText="Department" Visible="false" ReadOnly="true" />
                            <asp:BoundField DataField="CourseName" HeaderText="Course" ReadOnly="true" />
                       
                            <asp:TemplateField HeaderText="Year Level" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <%# Eval("YearLevel") %>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:DropDownList ID="ddlEditYearLevel" runat="server" CssClass="form-select form-select-sm">
                                    </asp:DropDownList>
                                </EditItemTemplate>
                            </asp:TemplateField>
                  
                            <asp:TemplateField HeaderText="Section" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <%# Eval("Section") %>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:TextBox ID="txtEditSection" runat="server" CssClass="form-control form-control-sm" 
                                        Text='<%# Bind("Section") %>'></asp:TextBox>
                                </EditItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Student Type" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
    <ItemTemplate>
        <span class='<%# GetStudentTypeClass(Eval("StudentType").ToString()) %>'>
            <i class='<%# GetStudentTypeIcon(Eval("StudentType").ToString()) %> me-1'></i>
            <%# Eval("StudentType") %>
        </span>
    </ItemTemplate>
    <EditItemTemplate>
        <asp:DropDownList ID="ddlEditStudentType" runat="server" CssClass="form-select form-select-sm"
            SelectedValue='<%# Bind("StudentType") %>'>
            <asp:ListItem Text="Regular" Value="Regular"></asp:ListItem>
            <asp:ListItem Text="Irregular" Value="Irregular"></asp:ListItem>
        </asp:DropDownList>
    </EditItemTemplate>
</asp:TemplateField>
                           
                            <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <span class='<%# GetStatusClass(Eval("Status").ToString()) %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-select form-select-sm"
                                        SelectedValue='<%# Bind("Status") %>'>
                                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                                        <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                        <asp:ListItem Text="Graduated" Value="Graduated"></asp:ListItem>
                                    </asp:DropDownList>
                                </EditItemTemplate>
                            </asp:TemplateField>
                            
                      
                            <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center">
                                <ItemTemplate>
                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-sm btn-primary" 
                                        CommandName="Edit" />
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-sm btn-danger" 
                                        CommandName="DeleteStudent" CommandArgument='<%# Eval("StudentID") %>'
                                        OnClientClick="return confirm('Are you sure you want to permanently delete this student?');" />
                                </ItemTemplate>
                                <EditItemTemplate>
                                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn btn-sm btn-success" 
                                        CommandName="Update" />
                                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-sm btn-secondary" 
                                        CommandName="Cancel" />
                                </EditItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pagination justify-content-center mt-3" />
                        <PagerSettings Mode="NumericFirstLast" PageButtonCount="5" 
                            FirstPageText="First" LastPageText="Last" />
                        <HeaderStyle CssClass="table-primary" />
                        <RowStyle CssClass="align-middle" />
                        <EmptyDataRowStyle CssClass="text-center py-5" />
                        <EmptyDataTemplate>
                            <div class="text-center py-4">
                                <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">No students found</h5>
                                <p class="text-muted">Try adjusting your search filters</p>
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Message Display -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="mt-3 alert alert-dismissible fade show alert-slide" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </asp:Panel>
    </form>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Validate bulk update before submission
        function validateBulkUpdate() {
            var yearLevel = $('#<%= ddlYearLevel.ClientID %>').val();
           var section = $('#<%= txtSection.ClientID %>').val();
    var status = $('#<%= ddlNewStatus.ClientID %>').val();
           var studentType = $('#<%= ddlNewStudentType.ClientID %>').val();

           // Check if at least one field is provided
           if (!yearLevel && !section && !status && !studentType) {
               alert('Please select at least one field to update.');
               return false;
           }

           return confirm('Update selected students with the chosen settings?');
       }

        // Update selected count display
        function updateSelectedCount() {
            var selectedCount = $('.row-checkbox:checked').length;
            $('#lblSelectedCountClient').text(selectedCount + ' selected');

            // Add visual feedback for selected rows
            $('.row-checkbox').each(function () {
                var row = $(this).closest('tr');
                if ($(this).is(':checked')) {
                    row.addClass('selected-row');
                } else {
                    row.removeClass('selected-row');
                }
            });
        }

        $(document).ready(function () {
            // Update selected count when checkboxes change
            $(document).on('change', '.row-checkbox', function () {
                updateSelectedCount();
            });

            // Initial count update
            updateSelectedCount();

            // Auto-hide alerts after 5 seconds
            setTimeout(function () {
                $('.alert').alert('close');
            }, 5000);

            // Add hover effects to table rows
            $('.table-hover tbody tr').hover(
                function () {
                    $(this).css('transform', 'translateY(-1px)');
                },
                function () {
                    $(this).css('transform', 'translateY(0)');
                }
            );
        });
    </script>
</body>
</html>


